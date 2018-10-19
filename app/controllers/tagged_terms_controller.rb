class TaggedTermsController < ApplicationController

  def index
    @all_tags = Tag.all
    @selected_tag = @all_tags.first
    @studies = Public::Study.tagged(@selected_tag.label).order(:brief_title)
    respond_to do |format|
      format.html
      format.csv { render text: @studies.to_csv }
      format.xls { render text: @studies.to_csv(col_sep: "\t") }
    end
  end

  def show
    @study = Public::Study.find(params[:id])
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def project_params
      params.fetch(:project, {})
      params.require(:project).permit(:utf8, :authenticity_token, :brief_title, :nct_id, :start_date, :phase, :id)
    end

end

