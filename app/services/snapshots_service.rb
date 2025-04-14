class SnapshotsService
  include Cacheable
  CACHE_LATEST_KEY = "latest_snapshots"

  self.cache_expiry = 30.minutes # configuration class level

  def initialize
    @api_client = AactApiClient.new
  end

  def fetch_latest_snapshots
    fetch_with_cache(CACHE_LATEST_KEY) do
      response = @api_client.get_latest_snapshots
      parse_and_validate_latest_response(response)
    end || []
  end


  def fetch_all_snapshots_by_type(type)
    response = @api_client.get_snapshots_by_type(type)

    # Check if it's an HTTParty response and extract the parsed_response
    if response.respond_to?(:parsed_response)
      data = response.parsed_response
    else
      data = response
    end

    # Process the response based on the new API structure
    if data.is_a?(Hash) && data[type].is_a?(Hash)
      # Return the structure directly as it already matches our expected format
      return {
        daily: data[type]["daily"] || [],
        monthly: data[type]["monthly"] || {}
      }
    else
      Rails.logger.error "Unexpected response format from API: #{response.inspect}"
      { daily: [], monthly: {} }
    end
  rescue StandardError => e
    Rails.logger.error "Error fetching snapshots by type: #{e.message}"
    { daily: [], monthly: {} }
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
end