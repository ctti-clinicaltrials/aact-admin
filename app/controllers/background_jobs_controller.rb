class BackgroundJobsController < ApplicationController

  def index
    @background_jobs = Core::BackgroundJob.all.order(created_at: :desc)
  end

  def show
  end

  def destroy
  end
end
