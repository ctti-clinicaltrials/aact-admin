class ApplicationController < ActionController::Base
  before_action :set_global_vars
  # Prevent CSRF attacks by raising an exception.
  layout "application"
  protect_from_forgery with: :exception

  def set_global_vars
    @aact_process_server       = AACT::Application::AACT_PROCESS_SERVER
    @aact_static_file_dir      = Rails.configuration.aact[:static_files_directory]
    @aact_public_database_name = AACT::Application::AACT_PUBLIC_DATABASE_NAME
    @aact_public_hostname      = AACT::Application::AACT_PUBLIC_HOSTNAME
    @aact_public_ip_address    = AACT::Application::AACT_PUBLIC_IP_ADDRESS
    @aact_db_version           = AACT::Application::AACT_DB_VERSION
    @aact_admin_usernames      = AACT::Application::AACT_ADMIN_USERNAMES
  end

  def is_admin?
      # check if user is an admin
      # if not admin, then redirect to root path
      redirect_to root_path if current_user.nil? || !current_user.admin?
  end
end
