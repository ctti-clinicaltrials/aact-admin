class BetaController < ApplicationController

  # def snapshots
  #   set_daily_monthly_snapshot_files
  # end

  # def pipe_files
  #   set_daily_monthly_pipe_files
  # end

  # def covid_19
  #   set_covid_pipe_files
  # end

  # def points_to_consider
  #   set_diagrams_and_dictionaries
  # end

  # def technical_documentation
  #   render plain: "Sorry - This page is only accessible to administrators." if !current_user_is_an_admin?
  #   set_diagrams_and_dictionaries
  # end

  # def learn_more
  #   set_diagrams_and_dictionaries
  # end

  def schema
    set_diagrams_and_dictionaries
    @show_dictionary_link = true
    @project_schema_files=Share::Project.schema_diagram_file_names
  end

  def show
    fpm=Util::FilePresentationManager.new
    @admin_schema_diagram=fpm.admin_schema_diagram
    @schema_diagram=fpm.schema_diagram
    @data_dictionary=fpm.data_dictionary
    @table_dictionary=fpm.table_dictionary
    @tables = []
    tabs=get_dictionary
    header = tabs.first
    (2..tabs.last_row).each do |i|
      row = Hash[[header, tabs.row(i)].transpose]
      if !row['table'].nil?
        @tables << fix_attribs(row)
      end
    end
  end
  # def covid_19_fields
  #   send_file(
  #     "#{Rails.root}/public/documentation/covid-19_field_explanation.xlsx",
  #     filename: "covid-19_field_explanation.xlsx",
  #     type: "application/xlsx"
  #   )
  # end

  # def psql
  # end

  def migration
  end

  private

  def set_daily_monthly_snapshot_files
    fpm=Util::FilePresentationManager.new
    @daily_files=fpm.daily_snapshot_files
    @archive_files=fpm.monthly_snapshot_files
  end

  def set_daily_monthly_pipe_files
    fpm=Util::FilePresentationManager.new
    @daily_files=fpm.daily_flat_files
    @archive_files=fpm.monthly_flat_files
  end

  def set_covid_pipe_files
    fpm=Util::FilePresentationManager.new
    @covid_19_files = fpm.covid_19_flat_files
  end


  def set_diagrams_and_dictionaries
    fpm=Util::FilePresentationManager.new
    @admin_schema_diagram=fpm.admin_schema_diagram
    @data_dictionary=fpm.data_dictionary
    @process_flow_diagram=fpm.process_flow_diagram
    @schema_diagram=fpm.schema_diagram
    @support_schema_diagram=fpm.support_schema_diagram
    @table_dictionary=fpm.table_dictionary
  end


  def current_user_is_an_admin?
    return false if !current_user
    col=AACT::Application::AACT_ADMIN_USERNAMES.split(',')
    col.include? current_user.username
  end

end
