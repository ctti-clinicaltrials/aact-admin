class Admin::DatabaseUsageController < ApplicationController
  before_action :is_admin?
  before_action :set_api_client
  DAYS_PER_PAGE = 10

  def dashboard
    # default to 10 days ending yesterday
    @end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.today.prev_day
    @start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : (@end_date - 9.days)

    if @end_date < @start_date
      @end_date = @start_date
    end

    if @end_date > Date.today
      @end_date = Date.today
    end

    @total_days = (@end_date - @start_date).to_i + 1
    @usage_data = fetch_database_usage_data(@start_date.to_s, @end_date.to_s)

    if @usage_data && @usage_data['metrics'].present?
      # sort metrics by date (most recent first)
      @all_metrics = @usage_data['metrics'].sort_by { |metric| Date.parse(metric['date']) }.reverse
      @date_range = "#{Date.parse(@usage_data['date_range']['start']).strftime('%b %d, %Y')} - #{Date.parse(@usage_data['date_range']['end']).strftime('%b %d, %Y')}"

      # paginate if more than 10 days
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

  def daily_usage
    @date = Date.parse(params[:date])
    @formatted_date = @date.strftime('%B %d, %Y')
    @user_data = fetch_daily_usage(@date.to_s)

    if @user_data.present? && @user_data['users'].present?
      @users = @user_data['users'].sort_by { |user| user['query_count'] }.reverse
      # Calculate summary statistics
      @total_users = @users.size
      @total_queries = @users.sum { |user| user['query_count'] }
      @total_duration = @users.sum { |user| user['total_duration_ms'].to_f }
      @avg_queries_per_user = @total_users > 0 ? (@total_queries.to_f / @total_users) : 0
    else
      @users = []
      @total_users = 0
      @total_queries = 0
      @total_duration = 0
      @avg_queries_per_user = 0
    end

    # TODO: improve this URL generation
    base_pgbadger_url = ENV['BASE_PGBADGER_URL']
    @pgbadger_url = "#{base_pgbadger_url}/#{@date.strftime('%Y-%m-%d')}.html"
  end

  private

  def set_api_client
    @api_client = AactApiClient.new
  end

  def fetch_database_usage_data(start_date, end_date)
    begin
      response = @api_client.get_database_usage(
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

  def fetch_daily_usage(date)
    begin
      response = @api_client.get_user_usage(start_date: date, end_date: date)

      if response.success?
        response.parsed_response
      else
        Rails.logger.error("Failed to fetch user usage data: #{response.code} #{response.message}")
        nil
      end
    rescue => e
      Rails.logger.error("Error fetching user usage data: #{e.message}")
      nil
    end
  end
end