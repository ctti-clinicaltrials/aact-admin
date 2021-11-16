require 'action_view'
require 'open-uri'
include ActionView::Helpers::NumberHelper
module Util
  class FilePresentationManager

    def nlm_protocol_data_url
      "https://prsinfo.clinicaltrials.gov/definitions.html"
    end

    def nlm_results_data_url
      "https://prsinfo.clinicaltrials.gov/results_definitions.html"
    end

    def monthly_snapshot_files(schema='')
      return Util::FileManager.new.files_in('beta_static_db_copies','monthly') if schema == 'beta'

      return Util::FileManager.new.files_in('archive_static_db_copies','monthly') if schema == 'archive'

      Util::FileManager.new.files_in('static_db_copies','monthly')
    end

    def daily_snapshot_files(schema='')
      return Util::FileManager.new.files_in('beta_static_db_copies','daily') if schema == 'beta'

      return Util::FileManager.new.files_in('archive_static_db_copies','monthly') if schema == 'archive'

      Util::FileManager.new.files_in('static_db_copies','daily')
    end

    def monthly_flat_files(schema='')
      return Util::FileManager.new.files_in('beta_exported_files','monthly') if schema == 'beta'

      Util::FileManager.new.files_in('exported_files','monthly')
    end

    def daily_flat_files(schema='')
      return Util::FileManager.new.files_in('beta_exported_files','daily') if schema == 'beta'

      return Util::FileManager.new.files_in('archive_exported_files','daily') if schema == 'archive'

      Util::FileManager.new.files_in('exported_files','daily')
    end

    def covid_19_flat_files
      Util::FileManager.new.files_in('exported_files','covid-19')
    end

    def root_dir
      '/static/documentation/'
    end

    def process_flow_diagram
      '/static/documentation/process_flow_diagram.png'
    end

    def support_schema_diagram
      "/static/documentation/aact_support_schema.png"
    end

    def admin_schema_diagram
      "/static/documentation/aact_admin_schema.png"
    end

    def schema_diagram
      "/documentation/aact_schema.png"
    end

    def schema_archive_diagram
      "/static/documentation/aact_archive_schema.png"
    end

    def nested_criteria_example
      "/static/documentation/nested_criteria_example.png"
    end

    def data_dictionary
      "/documentation/aact_data_definitions.xlsx"
    end

    def data_beta_dictionary
      "/static/documentation/aact_beta_data_definitions.xlsx"
    end

    def data_archive_dictionary
      "/static/documentation/aact_archive_data_definitions.xlsx"
    def view_beta_dictionary
      "/static/documentation/aact_beta_views.xlsx"
    end

    def view_dictionary
      "/static/documentation/aact_views.xlsx"
    end

    def table_dictionary
      "/documentation/aact_tables.xlsx"
    end

    def table_archive_dictionary
      "/static/documentation/aact_archive_tables.xlsx"
    end

    def table_beta_dictionary
      "/static/documentation/aact_beta_tables.xlsx"
    end

  end
end
