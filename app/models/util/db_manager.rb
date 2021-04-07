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
      result=Public::Study.connection.execute("select datconnlimit from pg_database where datname='aact';").first["datconnlimit"].to_i > 0
      # The AACT DBManager (in aact app) temporarily restricts access to the db (allowed connections set to zero) during db restore.
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

    def public_host_name
      AACT::Application::AACT_PUBLIC_HOSTNAME
    end

    def public_db_name
      AACT::Application::AACT_PUBLIC_DATABASE_NAME
    end

    def revoke_db_privs
      log "  db_manager: set connection limit so only db owner can login..."
      public_con.execute("ALTER DATABASE #{db_name} CONNECTION LIMIT 0;")
      public_alt_con.execute("ALTER DATABASE #{alt_db_name} CONNECTION LIMIT 0;")
    end

    def grant_db_privs
      public_con.execute("ALTER DATABASE #{db_name} CONNECTION LIMIT 200;")
      public_con.execute("GRANT USAGE ON SCHEMA ctgov TO read_only;")
      public_con.execute("GRANT SELECT ON ALL TABLES IN SCHEMA CTGOV TO READ_ONLY;")
      public_alt_con.execute("ALTER DATABASE #{alt_db_name} CONNECTION LIMIT 200;")
      public_alt_con.execute("GRANT USAGE ON SCHEMA ctgov TO read_only;")
      public_alt_con.execute("GRANT SELECT ON ALL TABLES IN SCHEMA CTGOV TO READ_ONLY;")
    end

    def alt_db_name
      AACT::Application::AACT_ALT_PUBLIC_DATABASE_NAME
    end

    def db_name
      AACT::Application::AACT_PUBLIC_DATABASE_NAME
    end
    def public_con
      return @public_con if @public_con and @public_con.active?
      PublicBase.establish_connection(public_db_url)
      @public_con = PublicBase.connection
      @public_con.schema_search_path='ctgov'
      return @public_con
    end

    def public_alt_con
      return @public_alt_con if @public_alt_con and @public_alt_con.active?
      PublicBase.establish_connection(alt_db_url)
      @public_alt_con = PublicBase.connection
      @public_alt_con.schema_search_path='ctgov'
      return @public_alt_con
    end

    # def con
    #   return @con if @con and @con.active?
    #   ActiveRecord::Base.establish_connection(back_db_url)
    #   @con = ActiveRecord::Base.connection
    #   @con.schema_search_path=@search_path
    #   return @con
    # end

  end

end
