namespace :backup do
  namespace :user_activity do
    task :run, [:force] => :environment do
      date_stamp=Time.zone.now.strftime('%Y%m%d')
      #TODO - abstract out the file name.
      #    Also...
      #       find most current activity count file
      #       check to see if it's already been loaded into db
      #       if not, load it
      file_name = "/aact-files/other/#{date_stamp}_user_activity_count.txt"
      DbUserActivity.populate_from_file(file_name)
    end
  end
end
