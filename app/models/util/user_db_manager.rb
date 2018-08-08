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
      cmd="/opt/rh/rh-postgresql96/root/bin/pg_dumpall -U  #{ENV['AACT_DB_SUPER_USERNAME']} -h #{public_host_name} --globals-only > #{fm.user_account_backup_file}"
      run_command_line(cmd)

      begin
        event=UserEvent.new({:event_type=>'backup', :file_names=>" #{fm.user_table_backup_file}, #{fm.user_event_table_backup_file}, #{fm.user_account_backup_file}" })
        UserMailer.send_backup_notification(event)
        event.save!
      rescue => error
        event.add_problem(error)
        event.save!
        return false
      end
    end

    def grant_db_privs(username)
      Public::Study.connection.execute("alter role \"#{username}\" IN DATABASE aact set search_path = ctgov;")
      Public::Study.connection.execute("grant connect on database aact to \"#{username}\";")
      Public::Study.connection.execute("grant usage on schema ctgov TO \"#{username}\";")
      Public::Study.connection.execute("grant select on all tables in schema ctgov to \"#{username}\";")
      Public::Study.connection.execute("alter user \"#{username}\" login;")
    end

    def revoke_db_privs(username)
      terminate_sessions_for(username)
      Public::Study.connection.execute("alter user \"#{username}\" nologin;")
    end

    def terminate_sessions_for(username)
       Public::Study.connection.execute("SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE pid <> pg_backend_pid() AND usename ='#{username}'")
    end
  end
end
