class DocumentationService
  include Cacheable

  CACHE_JSON_KEY = "docs_json"
  CACHE_CSV_KEY = "docs_csv"

  self.cache_expiry = 1.minutes

  def initialize
    @api_client = AactApiClient.new
  end

  def fetch_json_data
    fetch_with_cache(CACHE_JSON_KEY) do
      response = @api_client.get_documentation(csv: false)
      parse_and_validate_response(response, false)
    end || []
  end


  def fetch_csv_data
    fetch_with_cache(CACHE_CSV_KEY) do
      response = @api_client.get_documentation(csv: true)
      parse_and_validate_response(response, true)
    end || ""
  end


  def update_doc_item(doc_item, attrs)
    response = @api_client.update_documentation(doc_item["id"], attrs)
    if response.success?
      invalidate_cache(CACHE_JSON_KEY)
      invalidate_cache(CACHE_CSV_KEY)
      true
    else
      false
    end
  end

  private

  def parse_and_validate_response(response, csv)
    unless response.success?
      Rails.logger.error "API request failed: #{response.message} (Status: #{response.code})"
      return nil
    end

    data = csv ? response.body : response.parsed_response
    return nil if data.blank?

    data
  end
end