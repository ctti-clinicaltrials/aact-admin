require 'active_support/all'
class DbUserActivity < ActiveRecord::Base

  def self.populate_from_file(file_name, unit_of_time)
    when_recorded=file_name.split('/').last.split('_').first
    dataIn=File.open("#{file_name}")
    dataIn.each do |i|
      entry=i.strip
      new(:username      => entry.split(' ').last,
          :event_count   => entry.split(' ').first,
          :when_recorded => when_recorded,
          :unit_of_time  => unit_of_time
         ).save!
    end
  end

end
