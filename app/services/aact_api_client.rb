class AactApiClient

  def initialize
    @api_url = ENV["AACT_API_URL"]
  end


  # DOCUMENTATION
  def get_documentation(csv: false)
    headers = csv ? csv_headers : json_headers
    HTTParty.get("#{@api_url}/documentation", headers: headers)
  end

  def update_documentation(id, attrs)
    Rails.logger.info "Updating Schema Item (attrs: #{attrs})"
    HTTParty.patch("#{@api_url}/documentation/#{id}", body: {
        documentation: {
          description: attrs[:description],
          active: attrs[:active]
        }
      }.to_json, headers: json_headers)
  end

  # SNAPSHOTS
  def get_latest_snapshots
    HTTParty.get("#{@api_url}/snapshots/latest", headers: json_headers)
  end

  def get_snapshots_by_type(type)
    HTTParty.get("#{@api_url}/snapshots?type=#{type}", headers: json_headers)
  end

  private

  def csv_headers
    { "Accept" => "text/csv" }
  end

  def json_headers
    { "Content-Type" => "application/json", "Accept" => "application/json" }
  end
end