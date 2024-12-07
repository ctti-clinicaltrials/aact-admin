# app/services/documentation_service.rb
class DocumentationService
  CACHE_KEY = "docs_data"
  API_URL = ENV["DOCUMENTATION_API_URL_LOCAL"]

  def fetch_and_cache_data
    Rails.logger.info "Fetching documentation from Cache"
    Rails.cache.fetch(CACHE_KEY, expires_in: 10.minutes) do
      fetch_data_from_api
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

  def fetch_data_from_api
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
  end
end