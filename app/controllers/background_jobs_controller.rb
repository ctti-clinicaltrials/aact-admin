class BackgroundJobsController < ApplicationController
  before_action :set_background_job, only: [:destroy]

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
    @background_job.destroy
    redirect_to background_jobs_path, notice: "The background job was deleted successfully."
  end

  private
    def set_background_job
      @background_job = Core::BackgroundJob.find_by_id(params[:id])
      if @background_job.nil?
        render :file => "app/views/errors/not_found.html", status: :not_found
      end  
    end
end
