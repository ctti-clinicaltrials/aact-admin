class SharedDataController < ApplicationController

  def index
    @project_count = Share::Project.all.size
    @projects = Share::Project.order(:name)
    @projects_with_data = Share::Project.where('data_available is true').order(:name)
    respond_to do |format|
      format.html
      format.csv { render text: @projects.to_csv }
      format.xls { render text: @projects.to_csv(col_sep: "\t") }
    end
  end

  def show
    @project = Share::Project.where('schema_name = ?', params[:schema_name]).first
    @should_render_footer = false
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def project_params
      params.fetch(:project, {})
      params.require(:project).permit(:utf8, :authenticity_token, :schema_name, :id)
    end

end

