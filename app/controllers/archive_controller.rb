class ArchiveController < ApplicationController

  def archive
  end

  def data_dictionary
    fpm=Util::FilePresentationManager.new
    @admin_schema_diagram=fpm.admin_schema_diagram
    @schema_diagram=fpm.schema_archive_diagram
    @data_dictionary=fpm.data_archive_dictionary
    @table_dictionary=fpm.table_archive_dictionary
    @tables = []
    tabs=get_dictionary
    header = tabs.first
    (2..tabs.last_row).each do |i|
      row = Hash[[header, tabs.row(i)].transpose]
      if !row['table'].nil?
        @tables << fix_attribs(row)
      end
    end

    @view = []
    view_tabs=get_views
    view_header = view_tabs.first
    (2..view_tabs.last_row).each do |i|
      row = Hash[[header, view_tabs.row(i)].transpose]
      if !row['table'].nil?
        @view << fix_attribs(row)
      end
    end
  end


  def schema
    set_diagrams_and_dictionaries
    @show_dictionary_link = true
    @project_schema_files=Share::Project.schema_diagram_file_names
  end

  def download
  end

  def snapshots
    set_daily_monthly_snapshot_files
  end

  def pipe_files
    set_daily_monthly_pipe_files
  end

  def covid_19
    set_covid_pipe_files
  end

  private

  def get_dictionary
    Roo::Spreadsheet.open(Util::FileManager.new.table_archive_dictionary)
  end

  def get_views
    Roo::Spreadsheet.open(Util::FileManager.new.view_archive_dictionary)
  end

  def fix_attribs(hash)
    # get row count from the DataDefinition.row_count
    tab=hash['table'].downcase
    col=(tab=='studies' ? 'nct_id' : 'id')
    results=ActiveRecord::Base.connection.execute("SELECT row_count FROM data_definitions WHERE table_name='#{tab}' and column_name='#{col}'")
    if results.ntuples > 0
      row_count=results.getvalue(0,0).to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
      hash['row count']=row_count
    else
      hash['row count']=0
    end
    hash['formatted_table'] = "<span id='#{tab}'>#{hash['table']}</span>"
    hash
  end

  def set_diagrams_and_dictionaries
    fpm=Util::FilePresentationManager.new
    @admin_schema_diagram=fpm.admin_schema_diagram
    @data_dictionary=fpm.data_archive_dictionary
    @process_flow_diagram=fpm.process_flow_diagram
    @schema_diagram=fpm.schema_archive_diagram
    @support_schema_diagram=fpm.support_schema_diagram
    @table_dictionary=fpm.table_archive_dictionary
  end

  def set_daily_monthly_snapshot_files
    fpm = Util::FilePresentationManager.new
    @daily_files = fpm.daily_snapshot_files
    @archive_files = fpm.monthly_snapshot_files
    @beta_daily_files = fpm.daily_snapshot_files('beta')
    @beta_archive_files = fpm.monthly_snapshot_files('beta')
  end

  def set_daily_monthly_pipe_files
    fpm=Util::FilePresentationManager.new
    @daily_files=fpm.daily_flat_files
    @archive_files=fpm.monthly_flat_files
    @beta_daily_files=fpm.daily_flat_files('beta')
    @beta_archive_files=fpm.monthly_flat_files('beta')
  end

  def set_covid_pipe_files
    fpm=Util::FilePresentationManager.new
    @covid_19_files = fpm.covid_19_flat_files
  end


end
