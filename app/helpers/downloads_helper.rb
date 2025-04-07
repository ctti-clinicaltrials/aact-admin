module DownloadsHelper
  include ActionView::Helpers::TagHelper

  SNAPSHOT_CONFIG = {
    'pgdump' => {
      title: 'PostgreSQL Database Dump',
      description_title: 'About PostgreSQL Database Dump',
      view_all_text: 'Database Dumps',
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
      description_content: lambda do |helper|
        helper.safe_join([
          helper.content_tag(:p, 'Use these pipe-delimited text files to import AACT data into any database or analysis tool.'),
          helper.content_tag(:p, 'Each file corresponds to a table in the AACT database schema.')
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
end