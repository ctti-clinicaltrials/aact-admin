module Util
  class UserDbManager < DbManager

    def self.change_password(user, pwd)
      new.change_password(user, pwd)
    end

    def create_user_account(user)
      begin
        return false if !can_create_user_account?(user)
        Public::Study.connection.execute("create user \"#{user.username}\" password '#{user.password}';")
        Public::Study.connection.execute("alter user \"#{user.username}\" nologin;")  # can't login until they confirm their email
        return true
      rescue => e
        user.errors.add(:base, e.message)
        return false
      end
    end

    def can_create_user_account?(user)
      return false if user_account_exists?(user.username)
      return false if !public_db_accessible?
      return true
    end

    def user_account_exists?(username)
      return true if username == 'postgres'
      return true if username == 'ctti'
      Public::Study.connection.execute("SELECT usename FROM pg_catalog.pg_user where usename = '#{username}' UNION
                  SELECT groname  FROM pg_catalog.pg_group where groname = '#{username}'").count > 0
    end

    def remove_user(username)
      begin
        return false if !user_account_exists?(username)
        revoke_db_privs(username)
        Public::Study.connection.execute("REASSIGN owned by \"#{username}\" to postgres;")
        Public::Study.connection.execute("DROP owned by \"#{username}\";")
        Public::Study.connection.execute("REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA ctgov FROM \"#{username}\";")
        Public::Study.connection.execute("DROP user \"#{username}\";")
        return true
      rescue => e
        raise e
      end
    end

    def change_password(user,pwd)
      begin
         Public::Study.connection.execute("alter user \"#{user.username}\" password '#{pwd}';")
      rescue => e
        user.errors.add(:base, e.message)
      end
    end

    def backup_user_info
      fm=Util::FileManager.new
      fm.remove_todays_user_backup_tables

      log "dumping Users table..."
      cmd="pg_dump --no-owner --host=localhost -U #{ENV['AACT_DB_SUPER_USERNAME']} --table=Users  --data-only aact_admin > #{fm.user_table_backup_file}"
      run_command_line(cmd)

      log "dumping User events..."
      cmd="pg_dump --no-owner --host=localhost -U #{ENV['AACT_DB_SUPER_USERNAME']} --table=User_Events  --data-only aact_admin > #{fm.user_event_table_backup_file}"
      run_command_line(cmd)

      log "dumping User accounts..."
      cmd="pg_dumpall -U  #{ENV['AACT_DB_SUPER_USERNAME']} -h #{public_host_name} --globals-only > #{fm.user_account_backup_file}"
      run_command_line(cmd)

      begin
        check_for_backup_errors(event, fm)
        event.file_names = "#{fm.user_table_backup_file}, #{fm.user_event_table_backup_file}, #{fm.user_account_backup_file}"
        event.event_type = 'backup users'
        event.save!
        UserMailer.send_backup_notification(event)
      rescue => error
        event.add_problem(error)
        event.event_type = 'backup users problem'
        event.save!
        return false
      end
    end

    def check_for_backup_errors(event, fm)
      success_code=true
      fsize = File.size?(fm.user_event_table_backup_file)
      if fsize.nil? or fsize < 2500
        success_code = false
        event.event_type = 'backup users problem'
        event.add_problem("\nSize of #{fm.user_event_table_backup_file} is strangely small #{fsize}")
      end
      fsize = File.size?(fm.user_table_backup_file)
      if fsize.nil? or fsize < 2500
        success_code = false
        event.event_type = 'backup users problem'
        event.add_problem("\nSize of #{fm.user_table_backup_file} is strangely small #{fsize}")
      end
      fsize=File.size?(fm.user_account_backup_file)
      if fsize.nil? or fsize < 2500
        success_code = false
        event.event_type = 'backup users problem'
        event.add_problem("\nSize of #{fm.user_account_backup_file} is strangely small #{fsize} ")
      end
      return success_code
    end

    def grant_db_privs(username)
      byebug
      #  This grants db privs to individuals. A method to grant db privs to all users is in the AACT Application
      if Share::Project.count > 0
        project_schemas = ", #{Share::Project.schema_name_list}"
      else
        project_schemas = ""
      end

      Public::Study.connection.execute("grant read_only to \"#{username}\";")
      Public::Study.connection.execute("alter role \"#{username}\" login;")
      Public::Study.connection.execute("alter role \"#{username}\" IN DATABASE aact set search_path = ctgov, mesh_archive #{project_schemas};")
      Public::Study.connection.execute("alter role \"#{username}\" IN DATABASE aact_alt set search_path = ctgov, mesh_archive #{project_schemas};")
    end

    def revoke_db_privs(username)
      byebug
      #  This revokes db privs from individuals. A method to revoke db privs from all users is in the AACT Application
      terminate_sessions_for(username)
      Public::Study.connection.execute("revoke read_only from \"#{username}\";")
      Public::Study.connection.execute("alter user \"#{username}\" nologin;")
    end

    def grant_db_privs_to_everyone
      confirmed_users = User.all.select{ |user| user.confirmed? }
      confirmed_users.each {|user|
        begin
          grant_db_privs(user.username)
        rescue => error
          log error
        end
      }
    end

    def revoke_db_privs_from_everyone
      confirmed_users = User.all.select{ |user| user.confirmed? }
      confirmed_users.each {|user|
        begin
          revoke_db_privs(user.username)
        rescue => error
          log error
        end
      }
    end

    def terminate_sessions_for(username)
       Public::Study.connection.execute("SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE pid <> pg_backend_pid() AND usename ='#{username}'")
    end
  end
end
