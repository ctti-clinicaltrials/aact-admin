class PagesController < ApplicationController

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
    fpm=Util::FilePresentationManager.new
    @support_schema_diagram=fpm.support_schema_diagram
    @admin_schema_diagram=fpm.admin_schema_diagram
    @proj_schema_diagram=fpm.proj_schema_diagram
    @schema_diagram=fpm.schema_diagram
    @data_dictionary=fpm.data_dictionary
    @table_dictionary=fpm.table_dictionary
  end

  def technical_documentation
    render plain: "Sorry - This page is only accessible to administrators." if !current_user_is_an_admin?
    fpm=Util::FilePresentationManager.new
    @process_flow_diagram=fpm.process_flow_diagram
    @support_schema_diagram=fpm.support_schema_diagram
    @admin_schema_diagram=fpm.admin_schema_diagram
    @proj_schema_diagram=fpm.proj_schema_diagram
    @schema_diagram=fpm.schema_diagram
    @data_dictionary=fpm.data_dictionary
    @table_dictionary=fpm.table_dictionary
  end

  def learn_more
    fpm=Util::FilePresentationManager.new
    @process_flow_diagram=fpm.process_flow_diagram
    @support_schema_diagram=fpm.support_schema_diagram
    @admin_schema_diagram=fpm.admin_schema_diagram
    @proj_schema_diagram=fpm.proj_schema_diagram
    @schema_diagram=fpm.schema_diagram
    @data_dictionary=fpm.data_dictionary
    @table_dictionary=fpm.table_dictionary
  end

  def schema
    fpm=Util::FilePresentationManager.new
    @support_schema_diagram=fpm.support_schema_diagram
    @admin_schema_diagram=fpm.admin_schema_diagram
    @proj_schema_diagram=fpm.proj_schema_diagram
    @schema_diagram=fpm.schema_diagram
    @data_dictionary=fpm.data_dictionary
    @table_dictionary=fpm.table_dictionary
    @show_dictionary_link = true
  end

  private

  def current_user_is_an_admin?
    return false if !current_user
    col=ENV['AACT_ADMIN_USERNAMES'].split(',')
    col.include? current_user.username
  end

end
