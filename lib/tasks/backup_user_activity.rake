namespace :backup do
  namespace :user_activity do
    task :run, [:force] => :environment do
      DbUserActivity.get_info_from_logs
    end
  end
end
