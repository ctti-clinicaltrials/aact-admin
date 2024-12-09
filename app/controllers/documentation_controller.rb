require "csv"

class DocumentationController < ApplicationController

  before_action :is_admin?, only: [:edit, :update]
  before_action :set_documentation_service
  before_action :set_doc_item, only: [:show, :edit, :update]


  def index
    @docs = @docs_service.fetch_json_data
    if @docs.nil? || @docs.empty?
      # TODO: Empty State view instead of flash message
      flash[:alert] = "Failed to fetch documentation data."
      # TODO: Airbrake
      @docs = []
    end
    @docs = filter_data(@docs)
    @paginated_docs = Kaminari.paginate_array(@docs).page(params[:page]).per(20)
  end


  def show
  end

  def edit
  end

  def update
    if @docs_service.update_doc_item(@doc_item, doc_params)
      redirect_to documentation_path(@doc_item["id"]), notice: "Item Updated"
    else
      flash.now[:alert] = "Something went wrong. Please try again."
      # TODO: Airbrake
      render :edit
    end
  end

  def download_csv
    csv_data = @docs_service.fetch_csv_data
    if csv_data.nil? || csv_data.empty?
      flash[:alert] = "Something went wrong. Please try again later"
      # TODO: Airbrake
      redirect_to documentation_index_path
    else
      send_data csv_data, filename: "documentation_#{Time.now.strftime("%Y%m%d")}.csv", type: "text/csv"
    end
  end

  # TODO: Only save in case if response is success
  # TODO: Add error handling
  # TODO: Add Short Type for index view

  private

  def doc_params
    params.require(:doc_item).permit(:active, :description)
  end

  def set_documentation_service
    @docs_service = DocumentationService.new
  end

  def set_doc_item
    @doc_item = @docs_service.fetch_json_data.find { |doc| doc["id"] == params[:id].to_i }
    redirect_to documentation_index_path, alert: "Something went wrong" unless @doc_item
  end

  def filter_data(mappings)
  return mappings if params[:search].blank?

  search_term = params[:search].downcase
  mappings.select do |mapping|
    searchable_fields = [
      mapping["active"].to_s,
      mapping["table_name"],
      mapping["column_name"],
      mapping["data_type"],
      mapping["description"],
      mapping["ctgov_data_point_label"],
      mapping["ctgov_section"],
      mapping["ctgov_module"],
      mapping["ctgov_path"],
      mapping["ctgov_url_label"]
    ]

    searchable_fields.any? do |field|
      field.to_s.downcase.include?(search_term)
    end
  end
end
end