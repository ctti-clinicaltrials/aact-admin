class AactApiClient
  include HTTParty

  base_uri ENV["AACT_API_URL"]
  format :json
  headers 'Content-Type' => 'application/json', 'Accept' => 'application/json'

  def self.fetch_documentation(format: :json)
    headers = default_headers(format)
    puts "#{headers}"
    response = get('/documentation', headers: headers)
    # puts "#{response.first}"
    handle_response(response, format)
  end

  def self.update_documentation(id, attrs)
    Rails.logger.info "Updating Schema Item (attrs: #{attrs})"
    patch("/documentation/#{id}", body: attrs.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  private

  def self.default_headers(format)
    if format == :csv
      { 'Accept' => 'text/csv', 'Content-Type' => 'text/csv' }
    else
      { 'Accept' => 'application/json', 'Content-Type' => 'application/json' }
    end
  end

  def self.handle_response(response, format)
    if response.success?
      return response.parsed_response if format == :json
      response.body
    else
      Rails.logger.error "API request failed: #{response.message} (Status: #{response.code})"
      nil
    end
  rescue StandardError => e
    # TODO: Airbrake?
    Rails.logger.error "Exception during API request: #{e.message}"
    nil
  end
end