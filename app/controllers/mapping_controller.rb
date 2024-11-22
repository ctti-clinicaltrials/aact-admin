class MappingController < ApplicationController
  def index
    @mappings = fetch_and_cache_data
    @mappings = filter_data(@mappings)
    @paginated_mappings = Kaminari.paginate_array(@mappings).page(params[:page]).per(20)
  end

  private

  def fetch_and_cache_data
    Rails.logger.info "Fetching documentation from Cache"
    # Rails.cache.fetch("mapping_data", expires_in: 1.minutes) do
    #   fetch_data_from_api
    # end
    fetch_data_from_api
  end

  def fetch_data_from_api
    Rails.logger.info "Cache is not available -> Fetching documentation from API"
    # url = "http://localhost:3000/api/v1/documentation"
    url = "https://seashell-app-4caa4.ondigitalocean.app/api/v1/documentation"
    response = HTTParty.get(url)
    response.parsed_response
  rescue StandardError => e
    Rails.logger.error "Failed to fetch data: #{e.message}"
    []
  end

  def filter_data(mappings)
    puts "Filtering data", mappings
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