namespace :setup do
  task :databases => :environment do
    Util::DbManager.new.setup_db
  end
end