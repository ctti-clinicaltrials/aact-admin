class FaqController < ApplicationController
  before_action :authenticate_user

  private

  def authenticate_user
    unless user_signed_in? && current_user.admin?
      render 'errors/unauthorized_user', status: :forbidden
    end
  end
end