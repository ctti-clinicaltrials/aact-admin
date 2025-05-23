module DownloadsHelper
  include ActionView::Helpers::TagHelper

  # TODO: remove description_title
  SNAPSHOT_CONFIG = {
    'pgdump' => {
      title: 'PostgreSQL Database Dump', # PostgreSQL Database Dump
      description_title: 'About PostgreSQL Database Dump',
      view_all_text: 'Database Dumps',
      instructions_path: 'downloads/postgres_instructions',
      description_content: lambda do |helper|
        helper.safe_join([
          helper.content_tag(:p, 'Use this file to create a complete copy of the AACT database on your own PostgreSQL server.'),
          helper.content_tag(:div, helper.content_tag(:code, 'pg_restore -c -d your_database_name path_to_downloaded_file'), class: 'code-snippet'),
        ], "")
      end
    },
    'flatfiles' => {
      title: 'Flat Text Files',
      description_title: 'About Flat Files',
      view_all_text: 'Flat Files',
      instructions_path: 'downloads/flatfiles_instructions',
      description_content: lambda do |helper|
        helper.safe_join([
          helper.content_tag(:p, 'Use these pipe-delimited text files to import AACT data into any database or analysis tool. Each file corresponds to a table in the AACT database schema.'),
        ])

      end
    },
    'covid' => {
      title: 'COVID-19 Spreadsheets',
      description_title: 'About COVID-19 Spreadsheets',
      view_all_text: 'COVID-19 Spreadsheets',
      instructions_path: 'downloads/covid19_instructions',
      description_content: lambda do |helper|
        helper.safe_join([
          helper.content_tag(:p, 'These files contain current clinical studies related to COVID-19 from ClinicalTrials.gov as of the date of file creation. Each file allows users without advanced database skills to explore the trials in a spreadsheet format.'),
          helper.content_tag(:p) do
            helper.content_tag(:strong, 'Please Note: ') +
            'COVID-19 spreadsheets are no longer actively generated. Please check the "Last Exported" date above for the most recent available data.'
          end
        ])
      end
    }
  }

  def snapshot_title(type)
    SNAPSHOT_CONFIG.dig(type, :title) || "Unknown Snapshot Type"
  end

  def snapshot_description_title(type)
    SNAPSHOT_CONFIG.dig(type, :description_title) || "About This File"
  end

  def snapshot_view_all_text(type)
    SNAPSHOT_CONFIG.dig(type, :view_all_text) || "Snapshots"
  end

  def snapshot_description_content(type)
    content = SNAPSHOT_CONFIG.dig(type, :description_content)
    if content.is_a?(Proc)
      content.call(self)
    else
      content_tag(:p, "No description available yet.")
    end
  end

  def snapshot_instructions_path(type)
    SNAPSHOT_CONFIG.dig(type, :instructions_path)
  end
end