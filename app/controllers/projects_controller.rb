class ProjectsController < ApplicationController

  def index
    @project_count = Proj::Project.all.size
    @projects = Proj::Project.order(:name)
    @projects_with_data = Proj::Project.where('data_available is true').order(:name)
    respond_to do |format|
      format.html
      format.csv { render text: @projects.to_csv }
      format.xls { render text: @projects.to_csv(col_sep: "\t") }
    end
  end

  def show
    @project = Proj::Project.find(params[:id])
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def project_params
      params.fetch(:project, {})
      params.require(:project).permit(:utf8, :authenticity_token, :name, :investigators, :year, :description, :id)
    end

end

