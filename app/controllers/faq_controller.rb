class FaqController < ApplicationController
  before_action :authenticate_user, :set_global_vars

  private

  def set_global_vars
    @aact_public_database_name = AACT::Application::AACT_PUBLIC_DATABASE_NAME
    @aact_public_hostname = AACT::Application::AACT_PUBLIC_HOSTNAME
    @aact_public_ip_address = AACT::Application::AACT_PUBLIC_IP_ADDRESS
  end

  def authenticate_user
    render plain: "Sorry - This page is only accessible to administrators." if !current_user_is_an_admin?
  end

  def current_user_is_an_admin?
    return false if !current_user
    col=ENV['AACT_ADMIN_USERNAMES'].split(',')
    col.include? current_user.username
  end

end
