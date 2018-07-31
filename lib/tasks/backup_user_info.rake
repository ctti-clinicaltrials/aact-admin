namespace :backup do
  namespace :user_info do
    task :run, [:force] => :environment do
      Util::UserDbManager.new.backup_user_info
    end
  end
end
