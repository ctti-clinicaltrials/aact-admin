class SavedQueriesController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :catch_not_found
  before_action :set_saved_query, only: [:show]

  def index
    @saved_queries = SavedQuery.all.order(created_at: :desc)
  end
  
  def new
    @saved_query = SavedQuery.new
  end

  def show
  end

  def create
    @saved_query = SavedQuery.new(saved_query_params)
    @saved_query.user_id = current_user.id
    if @saved_query.save
      flash.notice = "The saved query record was created successfully."
      redirect_to @saved_query
    else
      flash.now.alert = @saved_query.errors.full_messages.to_sentence
      render :new
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_saved_query
      @saved_query = SavedQuery.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def saved_query_params
      params.require(:saved_query)
        .permit(:title, :description, :sql, :public)
    end

    def catch_not_found(e)
      Rails.logger.debug("We had a not found exception.")
      flash.alert = e.to_s
      redirect_to saved_queries_path
    end

end
