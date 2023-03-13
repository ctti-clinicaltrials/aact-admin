class BackgroundJobsController < ApplicationController
  before_action :set_background_job, only: [:show, :destroy]

  def index
    if current_user.admin?
      @background_jobs = BackgroundJob.all.order(created_at: :desc)
    else
      @background_jobs = BackgroundJob.where('user_id = ?', current_user.id).order(created_at: :desc)
    end  
  end

  def show
  end

  def destroy
    @background_job.destroy
    redirect_to background_jobs_path, notice: "The background job was deleted successfully."
  end

  private
    def set_background_job
      @background_job = BackgroundJob.find_by_id(params[:id])
      if @background_job.nil? || (@background_job.user_id != current_user.id && !current_user.admin?)
        render :file => "app/views/errors/not_found.html", status: :not_found
      end  
    end
end
