require 'active_support/all'
class DbUserActivity < ActiveRecord::Base

  def self.get_info_from_logs
    date_stamp=Time.zone.now.strftime('%Y%m%d')
    file_name = "/aact-files/other/#{date_stamp}_user_activity.txt"
    system("ssh ctti@174.138.61.222 sudo grep EDT /aact-files/logs/postgresql-*.log | cut -d ' ' -f 5 | sort | uniq -c > #{file_name}")
    populate_from_file(file_name,'weekly')
  end

  def self.populate_from_file(file_name, unit_of_time)
    file_datestamp = file_name.split('/').last.split('_').first
    if already_loaded?(file_datestamp.to_date)
      puts "Seems we've already loaded #{file_name}. Not gonna do it again."
      return false
    end
    dataIn=File.open("#{file_name}")
    dataIn.each do |i|
      entry=i.strip
      new(:username      => entry.split(' ').last,
          :event_count   => entry.split(' ').first,
          :when_recorded => file_datestamp,
          :unit_of_time  => unit_of_time
         ).save!
    end
  end

  def self.already_loaded?(dt)
    ! where("   extract(year from(when_recorded)) = ?
            and extract(month from(when_recorded)) = ?
            and extract(day from(when_recorded)) = ?", dt.year, dt.month, dt.day).empty?
  end

end
