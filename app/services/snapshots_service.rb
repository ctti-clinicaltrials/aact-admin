class SnapshotsService
  def initialize
    @api_client = AactApiClient.new
  end

  def fetch_latest_snapshots
    response = @api_client.get_latest_snapshots

    # Check if it's an HTTParty response and extract the parsed_response
    if response.respond_to?(:parsed_response)
      data = response.parsed_response
    else
      data = response
    end

    # Validate that it's an array with the expected structure
    if data.is_a?(Array) && data.all? { |item| item.is_a?(Hash) && item.key?("type") }
      return data
    else
      Rails.logger.error "Unexpected response format from API: #{response.inspect}"
      nil
    end
  rescue StandardError => e
    Rails.logger.error "Error fetching latest snapshots: #{e.message}"
    nil
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
end