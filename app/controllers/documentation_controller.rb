require "csv"

class DocumentationController < ApplicationController

  before_action :is_admin?, only: [:edit, :update]

  def index
    @docs = fetch_and_cache_data
    @docs = filter_data(@docs)
    # @paginated_docs = Kaminari.paginate_array(@docs).page(params[:page]).per(20)

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
    @doc_item = fetch_and_cache_data.find { |doc| doc["id"] == params[:id].to_i }
  end

  def edit
    @doc_item = fetch_and_cache_data.find { |doc| doc["id"] == params[:id].to_i }
    if @doc_item.nil?
      flash[:alert] = "Document not found."
      redirect_to documentation_index_path
    end
  end

  def update
    @doc_item = fetch_and_cache_data.find { |doc| doc["id"] == params[:id].to_i }
    if @doc_item
      @doc_item["active"] = doc_params[:active]
      @doc_item["description"] = doc_params[:description]
      puts "Updating document"
      puts "Params: #{doc_params}"

      response = send_doc_params_to_api(@doc_item["id"], doc_params)

      if response.success?
        Rails.cache.delete("mapping_data")
        flash[:notice] = "Document updated successfully."
      else
        flash[:alert] = "Failed to update document."
      end
      redirect_to documentation_path(@doc_item["id"])
    else
      flash[:alert] = "Document not found."
      redirect_to documentation_index_path
    end
  end

  # TODO: Only save in case if response is success
  # TODO: Add error handling
  # TODO: Add Short Type for index view

  private

  def doc_params
    params.require(:doc_item).permit(:active, :description)
  end

  def send_doc_params_to_api(id, doc_params)
    url = "http://127.0.0.1:3000/api/v1/documentation/#{id}"
    response = HTTParty.patch(url, body: { description: doc_params[:description], active: doc_params[:active] }.to_json, headers: { 'Content-Type' => 'application/json' })
    response
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

  def fetch_and_cache_data
    Rails.logger.info "Fetching documentation from Cache"
    Rails.cache.fetch("mapping_data", expires_in: 10.minutes) do
      fetch_data_from_api
    end
  end

  def fetch_data_from_api
    Rails.logger.info "Cache is not available -> Fetching documentation from API"
    url = ENV["DOCUMENTATION_API_URL"]
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