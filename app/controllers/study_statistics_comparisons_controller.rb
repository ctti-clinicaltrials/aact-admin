class StudyStatisticsComparisonsController < ApplicationController
  before_action :set_study_statistics_comparison, only: [:edit, :update, :destroy]
  
  def index
    @study_statistics_comparisons = Core::StudyStatisticsComparison.all.order(ctgov_selector: :desc)
  end

  def new
    @study_statistics_comparison = Core::StudyStatisticsComparison.new
  end

  def create
    @study_statistics_comparison = Core::StudyStatisticsComparison.new(study_statistics_comparison_params)
    if @study_statistics_comparison.save
      redirect_to study_statistics_comparisons_path, notice: "The study statistics comparison was created successfully."
    else
      flash.now.alert = @study_statistics_comparison.errors.full_messages.to_sentence
      render :new
    end
  end

  def edit
  end

  def update
    if @study_statistics_comparison.update(study_statistics_comparison_params)
      redirect_to study_statistics_comparisons_path, notice: "The study statistics comparison was updated successfully."
    else
      flash.now.alert = @study_statistics_comparison.errors.full_messages.to_sentence
      render :edit  
    end
  end

  def destroy
    @study_statistics_comparison.destroy
    redirect_to study_statistics_comparisons_path, notice: "The study statistics comparison was deleted successfully."
  end

  private
    def set_study_statistics_comparison
      @study_statistics_comparison = Core::StudyStatisticsComparison.find_by_id(params[:id])
      if @study_statistics_comparison.nil?
        render :file => "app/views/errors/not_found.html", status: :not_found
      end  
    end    

    # Only allow a list of trusted parameters through.
    def study_statistics_comparison_params
      params.require(:core_study_statistics_comparison).permit(:ctgov_selector, :table, :column, :condition, :instances_query, :unique_query)
    end
end
