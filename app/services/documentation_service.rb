# app/services/documentation_service.rb
class DocumentationService

  def fetch_json_data
    puts "Fetching JSON Data"
    data = fetch_and_cache_data(csv: false)
    # what are success and failure cases?
    # prepare or chack data format before returning to the controller
    # TODO: consider adding active model
    return data
  end

  def fetch_csv_data
    puts "Fetching CSV Data"
    data = fetch_and_cache_data(csv: true)

    # what are success and failure cases?
    # prepare or chack data format before returning to the controller csv data
    puts "CSV: #{data}"
    return data
    # return nil
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


  # generic method for checking cache -> calling api client -> caching the result if it was success
  def fetch_and_cache_data(csv: false)
    cache_key = csv ? "docs_csv" : "docs_json"
    Rails.logger.info "Checking cache for key: #{cache_key}"
    cached_data = Rails.cache.read(cache_key)
    return cached_data unless cached_data.nil?
    Rails.logger.info "Fetching data from API"

    data = AactApiClient.fetch_documentation(format: csv ? :csv : :json)
    if data.nil? || data.empty? # client returns nil, check can api return empty array?
      Rails.logger.warn "Not caching this result."
      return nil
    else
      Rails.logger.info "Caching data for key: #{cache_key}"
      Rails.cache.write(cache_key, data, expires_in: 10.minutes)
      return data
    end
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