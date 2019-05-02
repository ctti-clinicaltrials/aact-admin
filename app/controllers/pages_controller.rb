class PagesController < ApplicationController

  def sas
    set_global_vars
  end

  def r
    set_global_vars
  end

  def snapshots
    fpm=Util::FilePresentationManager.new
    @daily_files=fpm.daily_snapshot_files
    @archive_files=fpm.monthly_snapshot_files
  end

  def pipe_files
    fpm=Util::FilePresentationManager.new
    @daily_files=fpm.daily_flat_files
    @archive_files=fpm.monthly_flat_files
  end

  def points_to_consider
    set_diagrams_and_dictionaries
  end

  def technical_documentation
    render plain: "Sorry - This page is only accessible to administrators." if !current_user_is_an_admin?
    set_diagrams_and_dictionaries
  end

  def learn_more
    set_diagrams_and_dictionaries
  end

  def schema
    set_diagrams_and_dictionaries
    @show_dictionary_link = true
    @project_schema_files=Proj::Project.schema_diagram_file_names
  end

  private

  def set_global_vars
    @aact_public_database_name = AACT::Application::AACT_PUBLIC_DATABASE_NAME
    @aact_public_hostname = AACT::Application::AACT_PUBLIC_HOSTNAME
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
    col=ENV['AACT_ADMIN_USERNAMES'].split(',')
    col.include? current_user.username
  end

end
