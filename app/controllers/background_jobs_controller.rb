class BackgroundJobsController < ApplicationController
  before_action :set_background_job, only: [:show, :destroy]

  def index
    @background_jobs = filter_jobs(BackgroundJob.all)
  end

  def history
    @history = filter_jobs(BackgroundJob.where(user_id: current_user.id))
  end

  def show_results
    render template: 'playground/show_result'
  end

  def destroy
    @background_job.destroy
    redirect_to background_jobs_path, notice: "The background job was deleted successfully."
  end

  private

  def set_background_job
    @background_job = BackgroundJob.find_by_id(params[:id])
    if @background_job.nil? || (@background_job.user_id != current_user.id && !current_user.admin?)
      render file: "app/views/errors/not_found.html", status: :not_found
    end
  end

  def filter_jobs(jobs)
    if params[:search].present?
      search_params = params[:search].downcase
      jobs = jobs.where("lower(data::text) LIKE ?", "%#{search_params}%")
    end

    jobs.order(created_at: :asc).page(params[:page]).per(20)
  end
end
