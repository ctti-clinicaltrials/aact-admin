require 'rails_helper'

describe Util::FileManager do

  subject { described_class.new }

  context 'when removing daily files' do
    it 'does not delete files datestamped with current year/month' do
      dt = Time.zone.now
      year = dt.year
      month = dt.month.to_s.rjust(2, '0')
      Util::FileManager.new
      this_month_file="#{Rails.configuration.aact[:static_files_directory]}/static_db_copies/daily/#{year}#{month}02_clinical_trials.zip"
      system("rm #{Rails.configuration.aact[:static_files_directory]}/static_db_copies/daily/*") # remove everything from daily file directory
      expect(File.exist?(this_month_file)).to eq(false)
      system("touch #{this_month_file}")    # create file for this month
      expect(File.exist?(this_month_file)).to eq(true)
      subject.remove_daily_files
      expect(File.exist?(this_month_file)).to eq(true)  # this month's file should remain
    end

    it 'removes all files other than those datestamped with current year/month' do
      dt = Time.zone.now
      year  = dt.year
      month = (dt.month - 1).to_s.rjust(2, '0')
      if month == '00'
        month = '12'
        year  = year - 1
      end
      last_month_file="#{Rails.configuration.aact[:static_files_directory]}/static_db_copies/daily/#{year}#{month}02_clinical_trials.zip"

      system("rm #{Rails.configuration.aact[:static_files_directory]}/static_db_copies/daily/*") # remove everything from daily file directory
      system("touch #{last_month_file}")    # create file for last month
      expect(File.exist?(last_month_file)).to eq(true)
      subject.remove_daily_files
      expect(File.exist?(last_month_file)).to eq(false)  # last month's file should be gone
    end
  end

end
