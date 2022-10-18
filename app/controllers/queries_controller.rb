class QueriesController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :catch_not_found

  def new
    @query = Query.new
  end

  def create
    @query = Query.new(query_params)
    if @query.save
      flash.notice = "The query record was created successfully."
      redirect_to @query
    else
      flash.now.alert = @query.errors.full_messages.to_sentence
      render :new
    end
  end

  private

    # Only allow a list of trusted parameters through.
    def query_params
      params.require(:query)
        .permit(:title, :description, :sql, :public, :user)
    end

    def catch_not_found(e)
      Rails.logger.debug("We had a not found exception.")
      flash.alert = e.to_s
      redirect_to queries_path
    end

end
