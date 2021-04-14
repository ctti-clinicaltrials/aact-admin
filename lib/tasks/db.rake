namespace :db do
  task :setup_read_only => :environment do
    Util::DbManager.new.grant_privs_read_only
  end
end