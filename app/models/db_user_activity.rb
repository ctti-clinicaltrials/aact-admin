require 'active_support/all'
class DbUserActivity < ActiveRecord::Base

  def self.import_from_logs
    file_name = Util::FileManager.new.todays_db_activity_file
    system("ssh #{AACT::Application::AACT_DB_SUPER_USERNAME}@#{AACT::Application::AACT_DB_HOSTNAME} sudo grep STATEMENT /aact-files/logs/postgresql-*.log | grep -i select | cut -d ' ' -f 5 | sort | uniq -c > #{file_name}")
    populate_from_file(file_name,'weekly')
    update_user_records
  end

  def self.populate_from_file(file_name, unit_of_time)
    file_datestamp = file_name.split('/').last.split('_').first
    if already_loaded?(file_datestamp.to_date)
      puts "Seems we've already loaded #{file_name}. Not gonna do it again."
      return false
    end
    File.open(file_name).each do |i|
      entry=i.strip
      new(:username      => entry.split(' ').last,
          :event_count   => entry.split(' ').first,
          :when_recorded => file_datestamp,
          :unit_of_time  => unit_of_time
         ).save!
    end
  end

  def self.update_user_records
    active_users = uniq.pluck(:username)
    active_users.each{|username|
      user = User.where('username=?',username).try(:first)
      if !user.nil?
        user.skip_password_validation = true
        user.skip_username_validation = true
        activities = where('username = ?', username).group('username')
        user.db_activity =  activities.pluck("sum(event_count)").first
        user.last_db_activity = activities.pluck("max(when_recorded)").first
        user.save!
      end
    }
  end

  def self.already_loaded?(dt)
    ! where("   extract(year from(when_recorded)) = ?
            and extract(month from(when_recorded)) = ?
            and extract(day from(when_recorded)) = ?", dt.year, dt.month, dt.day).empty?
  end

  def display_when_recorded
    return '' if self.when_recorded.nil?
    self.when_recorded.strftime('%Y/%m/%d')
  end

end
