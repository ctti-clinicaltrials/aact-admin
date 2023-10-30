class PlaygroundController < ApplicationController

  def index
    if params[:query]
      # instead of running the query, create a background job if user has less than 10 jobs in the queue    
      if current_user.background_jobs.where(status: ['pending', 'running']).count < 10
        @background_job = BackgroundJob::DbQuery.create(user_id: current_user.id, status: 'pending', data: {query: params[:query]})
        redirect_to show_results_path(@background_job.id), notice: "The query was added to the queue successfully."
      else 
        flash.now.alert = "Cannot run query. You can only have a maximum of 10 queries in the queue."
      end   
    end  
  end

  def show_results
    @background_job = BackgroundJob.find_by_id(params[:id])
    if @background_job.url
      extractor = CsvDataExtractor.new(@background_job.url)
      headers, data = extractor.fetch_and_extract_data
      @headers = headers
      @data = data
    end
      if @background_job.nil? || (@background_job.user_id != current_user.id && !current_user.admin?)
        render :file => "app/views/errors/not_found.html", status: :not_found

      end 
  end
  
end