class SnapshotsService
  def initialize
    @api_client = AactApiClient.new
  end

  def fetch_latest_snapshots
    response = @api_client.get_latest_snapshots

    puts "Response: #{response.inspect}"  # Debugging line

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

  private

  def generate_daily_snapshots(type)
    # Generate mock data for the last 30 days
    snapshots = []

    30.times do |i|
      date = (Date.today - i.days).strftime("%m-%d-%Y")
      file_size = type == 'pgdump' ? "#{1.0 + (rand * 0.3).round(1)} GB" : "#{700 + rand(300)} MB"

      snapshots << {
        "type" => type,
        "date" => date,
        "file_name" => "aact-#{type}-#{date}.zip",
        "size" => file_size,
        "download_url" => "/downloads/#{type}/aact-#{type}-#{date}.zip"
      }
    end

    snapshots
  end

  def generate_monthly_snapshots(type)
    # Generate mock monthly snapshots grouped by year
    monthly_by_year = {}

    # Current year plus 2 previous years
    (Date.today.year - 2..Date.today.year).each do |year|
      months = []

      # For the current year, only include past months
      max_month = year == Date.today.year ? Date.today.month : 12

      max_month.times do |i|
        month = i + 1  # 1-based month
        date = Date.new(year, month, 1).strftime("%Y-%m-%d")
        file_size = type == 'pgdump' ? "#{1.0 + (rand * 0.3).round(1)} GB" : "#{700 + rand(300)} MB"

        months << {
          "type" => type,
          "date" => date,
          "file_name" => "aact-#{type}-#{date}.zip",
          "size" => file_size,
          "download_url" => "/downloads/#{type}/aact-#{type}-#{date}.zip"
        }
      end

      monthly_by_year[year.to_s] = months
    end

    monthly_by_year
  end

end