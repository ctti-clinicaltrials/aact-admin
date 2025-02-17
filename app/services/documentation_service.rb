# app/services/documentation_service.rb
class DocumentationService

  CACHE_JSON_KEY = "docs_json"
  CACHE_CSV_KEY = "docs_csv"

  def initialize
    @api_client = AactApiClient.new
  end

  def fetch_json_data
    data = fetch_and_cache_data(csv: false)
    # what are success and failure cases?
    # prepare or chack data format before returning to the controller
    # TODO: consider adding active model
    return data
  end

  def fetch_csv_data
    data = fetch_and_cache_data(csv: true)
    # TODO: consider adding active model
    return data
  end


  def update_doc_item(doc_item, attrs)
    response = @api_client.update_documentation(doc_item["id"], attrs)
    if response.success?
      invalidate_cache
      true
    else
      false
    end
  end

  private

  def invalidate_cache
    Rails.logger.info "Invalidating documentation cache"
    Rails.cache.write(CACHE_JSON_KEY, nil, force: true)
    Rails.cache.write(CACHE_CSV_KEY, nil, force: true)
  end

  def fetch_and_cache_data(csv: false)
    cache_key = csv ? CACHE_CSV_KEY : CACHE_JSON_KEY
    Rails.logger.info "Checking cache for key: #{cache_key}"

    cached_data = Rails.cache.read(cache_key)
    return cached_data if cached_data

    Rails.logger.info "Fetching data from API"
    response = @api_client.get_documentation(csv: csv)
    data = parse_and_validate_response(response, csv)

    if data
      Rails.cache.write(cache_key, data, expires_in: 10.minutes)
    else
      Rails.logger.warn "No valid data to cache."
    end

    data || default_empty_value(csv)
  end


  def parse_and_validate_response(response, csv)
    unless response.success?
      Rails.logger.error "API request failed: #{response.message} (Status: #{response.code})"
      return nil
    end

    data = csv ? response.body : response.parsed_response
    return nil if data.blank?

    data
  end

  def default_empty_value(csv)
    csv ? "" : []
  end
end