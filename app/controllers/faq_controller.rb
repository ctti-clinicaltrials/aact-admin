class FaqController < ApplicationController
  before_action :authenticate_user

  private

  def authenticate_user
    render plain: "Sorry - This page is only accessible to administrators." if !current_user_is_an_admin?
  end

  def current_user_is_an_admin?
    return false if !current_user
    col=AACT::Application::AACT_ADMIN_USERNAMES.split(',')
    col.include? current_user.username
  end

end
