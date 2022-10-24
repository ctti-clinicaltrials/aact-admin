class QueriesController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :catch_not_found

  def new
    @saved_query = SavedQuery.new
  end

  def create
    @saved_query = SavedQuery.new(saved_query_params)
    if @saved_query.save
      flash.notice = "The saved query record was created successfully."
      redirect_to @saved_query
    else
      flash.now.alert = @saved_query.errors.full_messages.to_sentence
      render :new
    end
  end

  private

    # Only allow a list of trusted parameters through.
    def saved_query_params
      params.require(:saved_query)
        .permit(:title, :description, :sql, :public, :user)
    end

    def catch_not_found(e)
      Rails.logger.debug("We had a not found exception.")
      flash.alert = e.to_s
      # redirect_to queries_path
    end

end
