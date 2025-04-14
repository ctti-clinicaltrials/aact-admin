class SnapshotsService
  include Cacheable
  CACHE_LATEST_KEY = "latest_snapshots"
  CACHE_TYPE_PREFIX = "snapshots_by_type_"

  # TODO: set different values for enviroments
  self.cache_expiry = 60.minutes # configuration class level

  def initialize
    @api_client = AactApiClient.new
  end

  # TODO: report errors to Airbrake
  def fetch_latest_snapshots
    fetch_with_cache(CACHE_LATEST_KEY) do
      response = @api_client.get_latest_snapshots
      parse_and_validate_latest_response(response)
    end || []
  end

  def fetch_all_snapshots_by_type(type)
    cache_key = "#{CACHE_TYPE_PREFIX}#{type}"
    fetch_with_cache(cache_key) do
      response = @api_client.get_snapshots_by_type(type)
      parse_and_validate_type_response(response, type)
    end || { daily: [], monthly: {} }
  end

  private

  def parse_and_validate_latest_response(response)
    unless response.success?
      Rails.logger.error "API request failed: #{response.message} (Status: #{response.code})"
      return nil
    end

    data = response.parsed_response

    if data.is_a?(Array) && data.all? { |item| item.is_a?(Hash) && item.key?("type") }
      return data
    else
      Rails.logger.error "Unexpected response format from API: #{data.inspect}"
      nil
    end
  end

  def parse_and_validate_type_response(response, type)
    unless response.success?
      Rails.logger.error "API request failed: #{response.message} (Status: #{response.code})"
      return nil
    end

    data = response.parsed_response # HTTParty response

    # process the response based on the expected API structure
    if data.is_a?(Hash) && data[type].is_a?(Hash)
      {
        daily: data[type]["daily"] || [],
        monthly: data[type]["monthly"] || {}
      }
    else
      Rails.logger.error "Unexpected response format from API: #{data.inspect}"
      nil
    end
  rescue StandardError => e
    Rails.logger.error "Error processing response in parse_and_validate_type_response: #{e.message}"
    nil
  end
end