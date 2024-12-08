# app/services/documentation_service.rb
class DocumentationService

  CACHE_KEY = "docs_json"
  CSV_CACHE_KEY = "docs_csv"


  def fetch_and_cache_data(format: :json)
    Rails.logger.info "Checking Cache for format: #{format}"
    cache_key = format == :csv ? CSV_CACHE_KEY : CACHE_KEY
    cached_data = Rails.cache.read(cache_key)
    return cached_data unless cached_data.nil?

    data = AactApiClient.fetch_documentation(format: format)
    if data.nil? || data.empty? # TODO: review what is falsey api response
      Rails.logger.warn "API returned nil, not caching this result."
      return nil
    else
      Rails.cache.write(cache_key, data, expires_in: 10.minutes)
      return data
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