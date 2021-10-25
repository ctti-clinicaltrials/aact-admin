require 'open3'
require 'action_view'
require 'open-uri'
include ActionView::Helpers::NumberHelper
RootDir = Rails.configuration.aact[:static_files_directory]
module Util
  class FileManager
    def initialize
      FileUtils.mkdir_p RootDir
      FileUtils.mkdir_p "#{RootDir}/static_db_copies/daily"
      FileUtils.mkdir_p "#{RootDir}/static_db_copies/monthly"
      FileUtils.mkdir_p "#{RootDir}/exported_files/daily"
      FileUtils.mkdir_p "#{RootDir}/exported_files/monthly"
      FileUtils.mkdir_p "#{RootDir}/db_backups"
      FileUtils.mkdir_p "#{RootDir}/documentation"
      FileUtils.mkdir_p "#{RootDir}/logs"
      FileUtils.mkdir_p "#{RootDir}/tmp"
      FileUtils.mkdir_p "#{RootDir}/other"
      FileUtils.mkdir_p "#{RootDir}/xml_downloads"
      FileUtils.mkdir_p "#{RootDir}/exported_files/covid-19"
    end

    def static_copies_directory
      if created_first_day_of_month? Time.zone.now.strftime('%Y%m%d')
        "#{RootDir}/static_db_copies/monthly"
      else
        "#{RootDir}/static_db_copies/daily"
      end
    end

    def flat_files_directory
      if created_first_day_of_month? Time.zone.now.strftime('%Y%m%d')
        "#{RootDir}/exported_files/monthly"
      else
        "#{RootDir}/exported_files/daily"
      end
    end

    def covid_19_files_directory
      "#{RootDir}/exported_files/covid-19"
    end

    def pg_dump_file
      "#{RootDir}/tmp/postgres.dmp"
    end

    def dump_directory
      "#{RootDir}/tmp"
    end

    def backup_directory
      "#{RootDir}/db_backups"
    end

    def xml_file_directory
      "#{RootDir}/xml_downloads"
    end

    def support_schema_diagram
      "#{RootDir}/documentation/aact_support_schema.png"
    end

    def admin_schema_diagram
      "#{RootDir}/documentation/aact_admin_schema.png"
    end

    def schema_diagram
      "#{RootDir}/documentation/aact_schema.png"
    end

    def data_dictionary
      "#{RootDir}/documentation/aact_data_definitions.xlsx"
    end

    def table_dictionary
      "#{RootDir}/documentation/aact_tables.xlsx"
    end

    def view_dictionary
      "#{RootDir}/documentation/aact_views.xlsx"
    end

    def default_mesh_terms
      "#{Rails.public_path}/mesh/mesh_terms.txt"
    end

    def default_mesh_headings
      "#{Rails.public_path}/mesh/mesh_headings.txt"
    end

    def default_data_definitions
      Roo::Spreadsheet.open("#{Rails.public_path}/documentation/aact_data_definitions.xlsx")
    end

    def files_in(sub_dir, type = nil)
      # type ('monthly' or 'daily') identify the subdirectory to use to get the files.
      entries = []
      dir = if type.blank?
              "#{RootDir}/#{sub_dir}"
            else
              "#{RootDir}/#{sub_dir}/#{type}"
            end
      file_names = Dir.entries(dir) - ['.', '..']
      dates = {}
      file_names.each do |file_name|
        begin
          file_url = "/static/#{sub_dir}/#{type}/#{file_name}"
          file = File.open("#{dir}/#{file_name}")
          size = file.size
          date_string = file_name.split('_').first
          date_created = (date_string.size == 8 || date_string.size == 14 ? Date.parse(date_string).strftime('%m/%d/%Y') : nil)
          time_created = (date_string.size == 14 ? DateTime.parse(date_string).strftime('%I:%M:%S %p') : nil)
          if downloadable?(file_name)
            entries << { name: file_name, date_created: date_created, size: number_to_human_size(size), url: file_url,
                         time_created: time_created }
          else
            puts "Not a downloadable file: #{file_name}"
          end
        rescue StandardError => e
          # just skip if unexpected file encountered
          puts "Skipping because #{e}"
        end
      end
      entries.sort_by { |entry| entry[:name] }.reverse!
    end

    def downloadable?(file_name)
      (file_name.size == 34 and file_name[30..34] == '.zip') or (file_name.size == 28 and file_name[24..28] == '.zip') or file_name =~ /covid-19|covid_19/i
    end

    def self.db_log_file_content(params)
      return [] if params.nil? || params[:day].nil?

      day = params[:day].capitalize
      file_name = "static/logs/postgresql-#{day}.log"
      if File.exist?(file_name)
        File.open(file_name)
      else
        []
      end
    end

    def todays_db_activity_file
      date_stamp = Time.zone.now.strftime('%Y%m%d')
      "#{RootDir}/other/#{date_stamp}_user_activity.txt"
    end

    def remove_todays_user_backup_tables
      File.delete(user_table_backup_file) if File.exist?(user_table_backup_file)
      File.delete(user_event_table_backup_file) if File.exist?(user_event_table_backup_file)
      File.delete(user_account_backup_file) if File.exist?(user_account_backup_file)
    end

    def user_table_backup_file
      file_prefix = "#{backup_directory}/#{Time.zone.now.strftime('%Y%m%d')}"
      "#{file_prefix}_aact_users_table.sql"
    end

    def user_event_table_backup_file
      file_prefix = "#{backup_directory}/#{Time.zone.now.strftime('%Y%m%d')}"
      "#{file_prefix}_aact_user_events_table.sql"
    end

    def user_account_backup_file
      file_prefix = "#{backup_directory}/#{Time.zone.now.strftime('%Y%m%d')}"
      "#{file_prefix}_aact_user_accounts.sql"
    end

    def make_file_from_website(fname, url)
      return_file = "#{RootDir}/tmp/#{fname}"
      File.delete(return_file) if File.exist?(return_file)
      open(url) do |site|
        open(return_file, 'wb') do |out_file|
          d = site.read
          out_file.write(d)
        end
      end
      File.open(return_file)
    end

    def get_dump_file_from(static_file)
      return static_file if `file --brief --mime-type "#{static_file}"` == "application/octet-stream\n"

      if `file --brief --mime-type "#{static_file}"` == "application/zip\n"
        Zip::File.open(static_file) do |zipfile|
          zipfile.each do |file|
            return file if file.name == 'postgres_data.dmp'
          end
        end
      end
    end

    def created_first_day_of_month?(str)
      day = str.split('/')[1]
      day == '01'
    end

    def save_static_copy
      fpm = Util::FilePresentationManager.new
      schema_diagram_file = File.open(schema_diagram.to_s)
      admin_schema_diagram_file = File.open(admin_schema_diagram.to_s)
      data_dictionary_file = File.open(data_dictionary.to_s)
      nlm_protocol_file = make_file_from_website('nlm_protocol_definitions.html', fpm.nlm_protocol_data_url)
      nlm_results_file = make_file_from_website('nlm_results_definitions.html', fpm.nlm_results_data_url)

      date_stamp = Time.zone.now.strftime('%Y%m%d')
      zip_file_name = "#{static_copies_directory}/#{date_stamp}_clinical_trials.zip"
      File.delete(zip_file_name) if File.exist?(zip_file_name)
      Zip::File.open(zip_file_name, Zip::File::CREATE) do |zipfile|
        zipfile.add('schema_diagram.png', schema_diagram_file)
        zipfile.add('admin_schema_diagram.png', admin_schema_diagram_file)
        zipfile.add('data_dictionary.xlsx', data_dictionary_file)
        zipfile.add('postgres_data.dmp', pg_dump_file)
        zipfile.add('nlm_protocol_definitions.html', nlm_protocol_file)
        zipfile.add('nlm_results_definitions.html', nlm_results_file)
      end
      zip_file_name
    end

    def remove_daily_files
      # keep files with current year/month datestamp
      keep = Time.zone.now.strftime('%Y%m')
      run_command_line("find #{Rails.configuration.aact[:static_files_directory]}/static_db_copies/daily -not -name '#{keep}*.zip' -print0 | xargs -0 rm --")
      run_command_line("find #{Rails.configuration.aact[:static_files_directory]}/exported_files/daily   -not -name '#{keep}*.zip' -print0 | xargs -0 rm --")
    end

    def run_command_line(cmd)
      stdout, stderr, status = Open3.capture3(cmd)
      success_code = false if status.exitstatus != 1
    end
  end
end
