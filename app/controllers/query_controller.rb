class QueryController < ApplicationController

  def index
    if params[:query]
      # instead of running the query, create a background job if user has less than 10 jobs in the queue    
      if current_user.background_jobs.where(status: ['pending', 'running']).count < 10
        @background_job = BackgroundJob::DbQuery.create(user_id: current_user.id, status: 'pending', data: {query: params[:query]})
        redirect_to background_job_path(@background_job.id), notice: "The query was added to the queue successfully."
      else 
        flash.now.alert = "Cannot run query. You can only have a maximum of 10 queries in the queue."
      end   
    end  
  end

end
