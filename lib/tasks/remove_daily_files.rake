namespace :remove do
  namespace :daily_files do
    task :run, [:force] => :environment do
      Util::FileManager.remove_daily_files
    end
  end
end
