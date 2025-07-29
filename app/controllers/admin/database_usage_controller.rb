class Admin::DatabaseUsageController < ApplicationController
  before_action :is_admin?

  def dashboard
    @message = "Welcome to the Database Usage Dashboard"
  end
end