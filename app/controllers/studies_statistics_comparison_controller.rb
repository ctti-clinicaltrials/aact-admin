class StudiesStatisticsComparisonController < ApplicationController
  
  def index
    @studies_statistics_comparison = Core::StudyStatisticsComparison.all.order(id: :desc)
  end

  def show
  end

  def new
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
  end
end
