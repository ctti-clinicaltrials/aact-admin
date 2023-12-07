class BackgroundJobsController < ApplicationController
  before_action :set_background_job, only: [:show, :destroy]

  def index
    @background_jobs = filter_jobs(BackgroundJob.all)
  end

  def admin_history
    @admin_history = search_background_jobs(BackgroundJob.all, params[:search])
               .order(created_at: :desc)
               .page(params[:page])
               .per(20)
  end

  def history
    base_query = user_signed_in? ? BackgroundJob.where(user_id: current_user.id) : BackgroundJob.where(user_id: nil)

    @history = search_background_jobs(base_query, params[:search])
               .order(created_at: :desc)
               .page(params[:page])
               .per(20)
  end

  def show
    render template: 'playground/show_results'
  end

  def destroy
    if current_user == @background_job.user
      @background_job.destroy
      redirect_to background_jobs_path, notice: "The background job was deleted successfully."
    else
      render_not_found
    end
  end

  private

  def set_background_job
    @background_job = BackgroundJob.find_by_id(params[:id])
    render_not_found if @background_job.nil?
  end

  def search_background_jobs(base_query, query)
    return base_query unless query.present?

    query = "%#{query.downcase}%"
    base_query.where("LOWER(data ->> 'query') LIKE ?", query)
  end

  def render_not_found
    render file: "app/views/errors/not_found.html", status: :not_found
  end
end
