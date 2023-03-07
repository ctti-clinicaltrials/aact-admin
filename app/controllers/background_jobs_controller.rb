class BackgroundJobsController < ApplicationController

  def index
    @background_jobs = Core::BackgroundJob.all.order(created_at: :desc)
  end

  def show
    @background_job = Core::BackgroundJob.find_by_id(params[:id])
    if @background_job.nil?
      render :file => "app/views/errors/not_found.html", status: :not_found
    end
  end

  def destroy
  end
end
