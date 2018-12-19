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
      @con ||= ActiveRecord::Base.establish_connection(ENV["AACT_BACK_DATABASE_URL"]).connection
    end

    def pub_con
      @pub_con ||= ActiveRecord::Base.establish_connection(ENV["AACT_PUBLIC_DATABASE_URL"]).connection
    end

    def public_host_name
      ENV['AACT_PUBLIC_HOSTNAME']
    end

    def public_db_name
      ENV['AACT_PUBLIC_DATABASE_NAME']
    end

  end

end
