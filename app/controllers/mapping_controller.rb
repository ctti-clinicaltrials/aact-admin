class MappingController < ApplicationController

  def index
    @mappings = fetch_data

    if params[:filter].present?
      @mappings = filter_data(@mappings, params[:filter])
    end
  end

  private


  def fetch_data
    url = "http://localhost:3000/api/v1/mapping"
    response = HTTParty.get(url)
    response.parsed_response # httparty parses based on content type

    rescue StandardError => e
      Rails.logger.error "Failed to fetch data: #{e.message}"
      []
  end


  def filter_data(data, filter)
    data.select { |item| item['field_name'].downcase.include?(filter.downcase) }
  end
end