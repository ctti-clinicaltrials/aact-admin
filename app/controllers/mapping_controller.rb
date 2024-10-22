class MappingController < ApplicationController

  def index
    @mappings = fetch_and_cache_data

    if params[:filter].present?
      @mappings = filter_data(@mappings, params[:filter])
    end

    @paginated_mappings = Kaminari.paginate_array(@mappings).page(params[:page]).per(5)
  end

  private

  # check if data is cached, if not, fetch from API
  def fetch_and_cache_data
    Rails.cache.fetch("mapping_data", expires_in: 4.hours) do
      fetch_data_from_api
    end
  end


  def fetch_data_from_api
    Rails.logger.info "Fetching mapping data from API"
    url = "http://localhost:3000/api/v1/mapping"
    response = HTTParty.get(url)
    response.parsed_response # httparty parses based on content type

    rescue StandardError => e
      Rails.logger.error "Failed to fetch data: #{e.message}"
      []
  end


  def filter_data(data, filter)
    data.select { |item| item['ctgov_path'].downcase.include?(filter.downcase) }
  end
end