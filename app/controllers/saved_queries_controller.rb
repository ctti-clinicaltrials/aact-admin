class SavedQueriesController < ApplicationController
  before_action :authenticate_user!, except: [:index]
  before_action :set_saved_query, only: [:edit, :update, :destroy]

  def index
    base_query = SavedQuery.where(public: true)

    if user_signed_in?
      base_query = base_query.or(SavedQuery.where(public: false, user_id: current_user.id))
    end
    
    if params[:search].present? || params[:search].blank?
      search_term = "%#{params[:search]}%"
      @saved_queries = base_query
        .where("LOWER(title) LIKE ? OR LOWER(description) LIKE ?", search_term.downcase, search_term.downcase)
        .order(created_at: :desc)
        .page(params[:page])
        .per(20)
    else
      @saved_queries = base_query
        .order(created_at: :desc)
        .page(params[:page])
        .per(20)
    end
  end
  
  def my_queries
    if params[:search].present? || params[:search].blank?
      search_term = "%#{params[:search]}%"
      @my_queries = SavedQuery.where(user_id: current_user.id)
                              .where("LOWER(title) LIKE ? OR LOWER(description) LIKE ?", search_term.downcase, search_term.downcase)
                              .order(created_at: :desc)
                              .page(params[:page])
                              .per(20)
    else
      @my_queries = SavedQuery.where(user_id: current_user.id)
                              .order(created_at: :desc)
                              .page(params[:page])
                              .per(20)
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
    unless current_user.admin? || current_user == @saved_query.user
      redirect_to :root, alert: "You are not authorized to edit this query."
    end
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
    unless current_user.admin? || current_user == @saved_query.user
      redirect_to :root, alert: "You are not authorized to update this query."
      return
    end

    if @saved_query.update(saved_query_params)
      flash.notice = "The query was updated successfully."
      redirect_to @saved_query
    else
      flash.now.alert = @saved_query.errors.full_messages.to_sentence
      render :edit  
    end  
  end

  def destroy
    unless current_user.admin? || current_user == @saved_query.user
      redirect_to :root, alert: "You are not authorized to delete this query."
      return
    end

    @saved_query.destroy
    redirect_to saved_queries_path, notice: "The query was deleted successfully."
  end

  private
    def set_saved_query
      @saved_query = SavedQuery.find_by_id(params[:id])
      if @saved_query.nil? || (@saved_query.user_id != current_user.id && !current_user.admin?)
        render :file => "app/views/errors/not_found.html", status: :not_found
      end
    end

    # Only allow a list of trusted parameters through.
    def saved_query_params
      params.require(:saved_query).permit(:title, :description, :sql, :public)
    end
end
