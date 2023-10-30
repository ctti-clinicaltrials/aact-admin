require 'csv'
require 'httparty'

class CsvDataExtractor
  def initialize(api_url)
    @api_url = api_url
  end

  def fetch_and_extract_data
    response = HTTParty.get(@api_url)

    if response.success?
      csv_data = response.body
      headers, data = parse_csv(csv_data)
      return headers, data[0...100] # Extract the first 100 rows
    else
      raise "Failed to fetch CSV data from the API: #{response.code}"
    end
  end

  private

  def parse_csv(csv_content)
    csv = CSV.parse(csv_content, headers: true)
    headers = csv.headers
    data = csv.to_a[1..-1] # Skip the first row (headers) and get the rest
    [headers, data]
  end
end