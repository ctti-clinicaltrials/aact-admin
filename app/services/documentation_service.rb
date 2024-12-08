# app/services/documentation_service.rb
class DocumentationService
  CACHE_KEY = "docs_json"
  CSV_CACHE_KEY = "docs_csv"
  API_URL = ENV["DOCUMENTATION_API_URL_LOCAL"]

  def fetch_and_cache_data
    Rails.logger.info "Fetching documentation from Cache"
    Rails.cache.fetch(CACHE_KEY, expires_in: 10.minutes) do
      fetch_data_from_api
    end
  end

  def fetch_csv_from_api
    Rails.logger.info "Fetching CSV documentation from Cache"
    Rails.cache.fetch(CSV_CACHE_KEY, expires_in: 10.minutes) do
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

  def update_doc_item(doc_item, attrs)
    response = update_data_in_api(doc_item["id"], attrs)
    if response.success?
      invalidate_cache
      true
    else
      false
    end
  end

  private

   # def fetch_data_from_api
  #   Rails.logger.info "Cache is not available -> Fetching documentation from API"
  #   url = ENV["DOCUMENTATION_API_URL_LOCAL"]
  #   response = HTTParty.get(url)
  #   response.parsed_response
  # rescue StandardError => e
  #   Rails.logger.error "Failed to fetch data: #{e.message}"
  #   []
  # end

  def fetch_data_from_api
    "No Cache -> Fetching documentation from API"
    response = HTTParty.get(API_URL)
    JSON.parse(response.body)
  end

  def update_data_in_api(id, attrs)
    HTTParty.patch(
      "#{API_URL}/#{id}",
       body: {
        documentation: {
          description: attrs[:description],
          active: attrs[:active]
        }
      }.to_json,
      headers: { 'Content-Type' => 'application/json' }
    )
  end

  def invalidate_cache
    Rails.cache.delete(CACHE_KEY)
    Rails.cache.delete(CSV_CACHE_KEY)
  end
end