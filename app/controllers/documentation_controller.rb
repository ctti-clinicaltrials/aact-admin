require "csv"

class DocumentationController < ApplicationController
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
        send_data csv_data[:body], filename: "documentation_#{Time.now.strftime('%Y%m%d')}.csv", type: 'text/csv'
      end
    end
  end

  # TODO: Only save in case if response is success
  # TODO: Add error handling

  private


  def fetch_csv_from_api
    Rails.logger.info "Fetching CSV documentation from Cache"
    Rails.cache.fetch("csv_mapping_data", expires_in: 1.minutes) do
      Rails.logger.info "Cache is not available -> Fetching CSV documentation from API"
      url = ENV["DOCUMENTATION_API_URL"]
      response = HTTParty.get(url, headers: { 'Accept' => 'text/csv' })

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
    Rails.cache.fetch("mapping_data", expires_in: 1.minutes) do
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
    mappings.select do |mapping|
      (params[:active].blank? || mapping['active'].to_s.include?(params[:active])) &&
      (params[:table_name].blank? || mapping['table_name'].include?(params[:table_name])) &&
      (params[:column_name].blank? || mapping['column_name'].include?(params[:column_name])) &&
      (params[:data_type].blank? || mapping['data_type'].include?(params[:data_type])) &&
      (params[:description].blank? || (mapping['description'] || 'N/A').include?(params[:description])) &&
      (params[:ctgov_data_point_label].blank? || (mapping['ctgov_data_point_label'] || 'N/A').include?(params[:ctgov_data_point_label])) &&
      (params[:ctgov_section].blank? || (mapping['ctgov_section'] || 'N/A').include?(params[:ctgov_section])) &&
      (params[:ctgov_module].blank? || (mapping['ctgov_module'] || 'N/A').include?(params[:ctgov_module])) &&
      (params[:ctgov_path].blank? || (mapping['ctgov_path'] || 'N/A').include?(params[:ctgov_path])) &&
      (params[:ctgov_url_label].blank? || (mapping['ctgov_url_label'] || 'N/A').include?(params[:ctgov_url_label]))
    end
  end


end