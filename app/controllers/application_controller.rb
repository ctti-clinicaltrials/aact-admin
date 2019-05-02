class ApplicationController < ActionController::Base
  before_action :set_global_vars
  # Prevent CSRF attacks by raising an exception.
  layout "application"
  protect_from_forgery with: :exception

  def set_global_vars
    @aact_public_database_name = AACT::Application::AACT_PUBLIC_DATABASE_NAME
    @aact_public_hostname = AACT::Application::AACT_PUBLIC_HOSTNAME
    @aact_public_ip_address = AACT::Application::AACT_PUBLIC_IP_ADDRESS
  end

end
