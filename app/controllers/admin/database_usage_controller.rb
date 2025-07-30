class Admin::DatabaseUsageController < ApplicationController
  before_action :is_admin?
  before_action :set_api_client
  DAYS_PER_PAGE = 10

  def dashboard
    # Get date range from params or default to last 10 days
    @start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : (Date.today - 9.days)
    @end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.today

    # Ensure end_date is not before start_date
    if @end_date < @start_date
      @end_date = @start_date
    end

    # Calculate total days in range
    @total_days = (@end_date - @start_date).to_i + 1

    # Fetch all data for the date range
    @usage_data = fetch_database_usage_data('daily', @start_date.to_s, @end_date.to_s)

    if @usage_data && @usage_data['metrics'].present?
      # TODO: update sort order on the backend
      @all_metrics = @usage_data['metrics'].sort_by { |metric| Date.parse(metric['date']) }.reverse
      @date_range = "#{Date.parse(@usage_data['date_range']['start']).strftime('%b %d, %Y')} - #{Date.parse(@usage_data['date_range']['end']).strftime('%b %d, %Y')}"

      # Use pagination if more than 10 days
      if @total_days > DAYS_PER_PAGE
        @use_pagination = true
        @paginated_metrics = Kaminari.paginate_array(@all_metrics).page(params[:page]).per(DAYS_PER_PAGE)
        @metrics = @paginated_metrics
      else
        @use_pagination = false
        @metrics = @all_metrics
      end
    else
      @all_metrics = []
      @metrics = []
      @date_range = "#{@start_date.strftime('%b %d, %Y')} - #{@end_date.strftime('%b %d, %Y')}"
      @use_pagination = false
    end
  end

  private

  def set_api_client
    @api_client = AactApiClient.new
  end

  def fetch_database_usage_data(period, start_date, end_date)
    begin
      response = @api_client.get_database_usage(
        period: period,
        start_date: start_date,
        end_date: end_date
      )

      if response.success?
        response.parsed_response
      else
        Rails.logger.error("Failed to fetch database usage data: #{response.code} #{response.message}")
        nil
      end
    rescue => e
      Rails.logger.error("Error fetching database usage data: #{e.message}")
      nil
    end
  end
end