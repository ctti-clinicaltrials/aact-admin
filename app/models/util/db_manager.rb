require 'open3'
module Util
  class DbManager

    attr_accessor :con, :pub_con, :event

    def initialize(params={})
      if params[:event]
        @event = params[:event]
      else
        @event = UserEvent.new
      end
    end

    def public_db_accessible?
      result=Public::Study.connection.execute("select datconnlimit from pg_database where datname='aact';").first["datconnlimit"].to_i
      return false if result == 0
      # The AACT DBManager (in aact app) temporarily restricts access to the db (allowed connections set to zero) during db restore.
      
      true
    end

    def run_command_line(cmd)
      stdout, stderr, status = Open3.capture3(cmd)
      if status.exitstatus != 0
        event.add_problem("#{Time.zone.now}: #{stderr}")
        success_code=false
      end
    end

    def log(msg)
      puts "#{Time.zone.now}: #{msg}"  # log to STDOUT
    end

    def public_study_count
      Public::Study.connection.execute("select count(*) from studies").values.flatten.first.to_i
    end

    def background_study_count
      con.execute("select count(*) from studies").values.flatten.first.to_i
    end

    def con
      @con ||= ActiveRecord::Base.establish_connection(AACT::Application::AACT_BACK_DATABASE_URL).connection
    end

    def pub_con
      @pub_con ||= ActiveRecord::Base.establish_connection(AACT::Application::AACT_PUBLIC_DATABASE_URL).connection
    end

    def beta_con
      @beta_con ||= ActiveRecord::Base.establish_connection(AACT::Application::AACT_BETA_DATABASE_URL).connection
    end

    def public_host_name
      AACT::Application::AACT_PUBLIC_HOSTNAME
    end

    def public_db_name
      AACT::Application::AACT_PUBLIC_DATABASE_NAME
    end

    def beta_db_name
      AACT::Application::AACT_BETA_DATABASE_NAME
    end

    def grant_privs_read_only
      pub_con.execute("grant connect on database #{public_db_name} to read_only;")
      pub_con.execute('grant usage on schema ctgov to read_only;')
      pub_con.execute('grant select on all tables in schema ctgov to read_only;')
      pub_con.execute('alter default privileges in schema ctgov grant select on tables to read_only;')
      beta_con.execute("grant connect on database #{beta_db_name} to read_only;")
      beta_con.execute('grant usage on schema ctgov_beta to read_only;')
      beta_con.execute('grant select on all tables in schema ctgov_beta to read_only;')
      beta_con.execute('alter default privileges in schema ctgov_beta grant select on tables to read_only;')
    end

  end

end
