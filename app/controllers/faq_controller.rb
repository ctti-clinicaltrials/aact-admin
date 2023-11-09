class FaqController < ApplicationController
  before_action :authenticate_user

  private

  def authenticate_user
    unless user_signed_in? && current_user.admin?
      render file: Rails.root.join('app', 'views', 'errors', 'unauthorized_user.html.erb'), layout: true, status: :forbidden
    end
  end
end