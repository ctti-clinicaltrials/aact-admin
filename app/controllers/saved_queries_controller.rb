class SavedQueriesController < ApplicationController
  before_action :authenticate_user!, except: [:index]
  before_action :set_saved_query, only: [:edit, :update, :destroy]

  def index
    if user_signed_in?      
      @saved_queries = SavedQuery.where('public = true OR (public = false AND user_id = ?)', current_user.id).order(created_at: :desc)  
    else
      @saved_queries = SavedQuery.where('public = true').order(created_at: :desc)  
    end
  end
  
  def new
    @saved_query = SavedQuery.new
  end

  def show
    @saved_query = SavedQuery.find_by_id(params[:id])
    if @saved_query.nil? || (@saved_query.user_id != current_user.id && !@saved_query.public)
      render :file => "app/views/errors/not_found.html", status: :not_found
    end
  end

  def edit
  end

  def create
    @saved_query = SavedQuery.new(saved_query_params)
    @saved_query.user_id = current_user.id
    if @saved_query.save
      redirect_to saved_query_path(@saved_query), notice: "The query was created successfully."
    else
      flash.now.alert = @saved_query.errors.full_messages.to_sentence
      render :new
    end
  end

  def update
    if @saved_query.update(saved_query_params)
      flash.notice = "The query was updated successfully."
      redirect_to @saved_query
    else
      flash.now.alert = @saved_query.errors.full_messages.to_sentence
      render :edit  
    end  
  end

  def destroy
    @saved_query.destroy
    redirect_to saved_queries_path, notice: "The query was deleted successfully."
  end

  private
    def set_saved_query
      @saved_query = SavedQuery.find_by_id(params[:id])
      if @saved_query.nil? || @saved_query.user_id != current_user.id
        render :file => "app/views/errors/not_found.html", status: :not_found
      end  
    end

    # Only allow a list of trusted parameters through.
    def saved_query_params
      params.require(:saved_query).permit(:title, :description, :sql, :public)
    end
end
