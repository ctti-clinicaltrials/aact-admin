namespace :backup do
  namespace :user_activity do
    task :run, [:force] => :environment do
      DbUserActivity.import_from_logs
    end
  end
end
