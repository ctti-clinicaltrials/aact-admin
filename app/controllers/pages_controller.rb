class PagesController < ApplicationController

  def airbrake
    this_method_is_missing
  end

  def home
    @notice=Notice.where(visible: true).order(created_at: :desc).first
  end

  def download
    @daily_snapshots = Core::FileRecord.daily('snapshot')
    @monthly_snapshots = Core::FileRecord.monthly('snapshot')
    @daily_pipefiles = Core::FileRecord.daily('pipefiles')
    @monthly_pipefiles = Core::FileRecord.monthly('pipefiles')
    @daily_covid_19 = Core::FileRecord.everything('covid-19')
  end
  
  def snapshots
    @daily = Core::FileRecord.daily('snapshot')
    @monthly = Core::FileRecord.monthly('snapshot')
  end

  def pipe_files
    @daily = Core::FileRecord.daily('pipefiles')
    @monthly = Core::FileRecord.monthly('pipefiles')
  end

  def covid_19
    @daily = Core::FileRecord.everything('covid-19')
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
    @project_schema_files=Share::Project.schema_diagram_file_names
  end

  def covid_19_fields
    send_file(
      "#{Rails.root}/public/documentation/covid-19_field_explanation.xlsx",
      filename: "covid-19_field_explanation.xlsx",
      type: "application/xlsx"
    )
  end

  def postgres
  end

  private

  def set_daily_monthly_snapshot_files
    fpm = Util::FilePresentationManager.new
    @daily_files = fpm.daily_snapshot_files
    @archive_files = fpm.monthly_snapshot_files
    # @beta_daily_files = fpm.daily_snapshot_files('beta')
    # @beta_archive_files = fpm.monthly_snapshot_files('beta')
  end

  def set_daily_monthly_pipe_files
    fpm=Util::FilePresentationManager.new
    @daily_files=fpm.daily_flat_files
    @archive_files=fpm.monthly_flat_files
    # @beta_daily_files=fpm.daily_flat_files('beta')
    # @beta_archive_files=fpm.monthly_flat_files('beta')
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
