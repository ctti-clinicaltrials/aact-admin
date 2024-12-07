require "csv"

class DocumentationController < ApplicationController

  before_action :is_admin?, only: [:edit, :update]
  before_action :set_documentation_service
  before_action :set_doc_item, only: [:show, :edit, :update]

  def index
    @docs = @docs_service.fetch_and_cache_data
    @docs = filter_data(@docs)

    respond_to do |format|
      format.html do
        @paginated_docs = Kaminari.paginate_array(@docs).page(params[:page]).per(20)
      end
      format.csv do
        csv_data = fetch_csv_from_api
        send_data csv_data[:body], filename: "documentation_#{Time.now.strftime("%Y%m%d")}.csv", type: "text/csv"
      end
    end
  end

  def show
  end

  def edit
    @doc_item = @docs_service.fetch_and_cache_data.find { |doc| doc["id"] == params[:id].to_i }
    if @doc_item.nil?
      flash[:alert] = "Document not found."
      redirect_to documentation_index_path
    end
  end


  def update
    if @docs_service.update_doc_item(@doc_item, doc_params)
      redirect_to documentation_path(@doc_item["id"]), notice: "Item Updated"
    else
      flash.now[:alert] = "Something went wrong. Please try again."
      render :edit
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
    @doc_item = @docs_service.fetch_and_cache_data.find { |doc| doc["id"] == params[:id].to_i }
    redirect_to documentation_index_path, alert: "Something went wrong" unless @doc_item
  end

  def fetch_documentation_format(format)
    url = ENV["DOCUMENTATION_API_URL"]
    if format == "csv"
      response = HTTParty.get(url, headers: { "Accept" => "text/csv" })
    elif format == "html"
      response = HTTParty.get(url)
    else
      puts "Invalid format"
    end
  end

  def handle_csv_response(response)
  end

  def handle_html_response(response)

  end

  def fetch_csv_from_api
    Rails.logger.info "Fetching CSV documentation from Cache"
    Rails.cache.fetch("csv_mapping_data", expires_in: 10.minutes) do
      Rails.logger.info "Cache is not available -> Fetching CSV documentation from API"
      url = ENV["DOCUMENTATION_API_URL"]
      response = HTTParty.get(url, headers: { "Accept" => "text/csv" })

      if response.success?
        { body: response.body }
      else
        Rails.logger.error "Failed to fetch CSV data: #{response.message}"
        { body: "" }
      end
    rescue StandardError => e
      Rails.logger.error "Failed to fetch CSV data: #{e.message}"
      { body: "" }
    end
  end

  def fetch_data_from_api
    Rails.logger.info "Cache is not available -> Fetching documentation from API"
    url = ENV["DOCUMENTATION_API_URL_LOCAL"]
    response = HTTParty.get(url)
    response.parsed_response
  rescue StandardError => e
    Rails.logger.error "Failed to fetch data: #{e.message}"
    []
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