class StudySearchesController < ApplicationController
  before_action :set_study_search, only: [:edit, :update, :destroy]

  def index
    @study_searches = Core::StudySearch.all
  end

  def new
    @study_search = Core::StudySearch.new
  end

  def create
    @study_search = Core::StudySearch.new(study_search_params)
    if @study_search.save
      redirect_to study_searches_path, notice: "The study search was created successfully."
    else
      flash.now.alert = @study_search.errors.full_messages.to_sentence
      render :new
    end
  end

  def edit
  end


  
  def update
    if @study_search.update(study_search_params)
      redirect_to study_searches_path, notice: "The study search was updated successfully."
    else
      flash.now.alert = @study_search.errors.full_messages.to_sentence
      render :edit  
    end
  end

  def destroy
    @study_search.destroy
    redirect_to study_searches_path, notice: "The study searches was deleted successfully."
  end

  private
    def set_study_search
      @study_search = Core::StudySearch.find_by_id(params[:id])
      if @study_search.nil?
        render :file => "app/views/errors/not_found.html", status: :not_found
      end  
    end    

    # Only allow a list of trusted parameters through.
    def study_search_params
      params.require(:core_study_search).permit(:save_tsv, :query, :grouping, :name, :beta_api, :checkbox_value)
    end
end
