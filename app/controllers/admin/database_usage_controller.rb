class Admin::DatabaseUsageController < ApplicationController
  before_action :is_admin?

  DAYS_PER_PAGE = 10
  DEFAULT_DATE_RANGE_DAYS = 9  # For 10 total days (including end date)
  DATA_COLLECTION_START_DATE = Date.new(2025, 6, 6)  # Database usage data collection started on this date

  def dashboard
    # Validate and prepare dates
    dates = validate_and_prepare_dates(params[:start_date], params[:end_date])

    if dates.nil?
      # Validation failed - redirect back with error
      redirect_to admin_dashboard_path and return
    end

    @start_date = dates[:start_date]
    @end_date = dates[:end_date]

    service = DatabaseUsageService.new
    result = service.fetch_dashboard_data(@start_date.to_s, @end_date.to_s)

    @usage_data = result[:usage_data]
    @total_days = result[:total_days]

    # Detect future dates
    @has_future_dates = @end_date > Date.today || @start_date > Date.today
    @is_future_range = @start_date > Date.today

    # Detect dates before data collection started
    @has_pre_collection_dates = @start_date < DATA_COLLECTION_START_DATE
    @is_pre_collection_range = @end_date < DATA_COLLECTION_START_DATE

    prepare_dashboard_view_vars
  end

  def daily_usage
    # For daily usage, we expect a single date parameter
    date_param = params[:date] || params[:start_date] || Date.yesterday.to_s
    @date = Date.parse(date_param)

    # Detect if date is in the future for better messaging
    @is_future_date = @date > Date.today

    # Detect if date is before data collection started
    @is_pre_collection_date = @date < DATA_COLLECTION_START_DATE

    service = DatabaseUsageService.new
    result = service.fetch_daily_usage(@date.to_s)

    @user_data = result[:user_data]
    @formatted_date = result[:formatted_date]
    @stats = result[:stats]
    @pgbadger_url = result[:pgbadger_url]

    prepare_daily_usage_view_vars
  end

  private

  def validate_and_prepare_dates(start_param, end_param)
    # Parse or set defaults
    end_date = end_param.present? ? Date.parse(end_param) : Date.yesterday
    start_date = start_param.present? ? Date.parse(start_param) : (end_date - DEFAULT_DATE_RANGE_DAYS.days)

    # Validate date range
    if start_date > end_date
      flash[:error] = "Start date cannot be after end date. Please select a valid date range."
      return nil
    end
    { start_date: start_date, end_date: end_date }
  end

  def prepare_dashboard_view_vars
    if @usage_data && @usage_data['metrics'].present?
      @all_metrics = @usage_data['metrics'].sort_by { |m| Date.parse(m['date']) }.reverse
      @date_range = format_date_range(@usage_data['date_range'])
      pagination_result = paginate_metrics(@all_metrics, @total_days)
      @metrics = pagination_result[:metrics]
      @use_pagination = pagination_result[:use_pagination]

      # Calculate period-level statistics
      @avg_users_per_period = @all_metrics.sum { |m| m['unique_users'] } / @all_metrics.size.to_f
      @max_users_per_period = @all_metrics.map { |m| m['unique_users'] }.max
      @min_users_per_period = @all_metrics.map { |m| m['unique_users'] }.min
      @avg_queries_per_period = @all_metrics.sum { |m| m['total_queries'] } / @all_metrics.size.to_f
    else
      @all_metrics = []
      @metrics = []
      @date_range = format_date_range({ 'start' => @start_date, 'end' => @end_date })
      @use_pagination = false

      # Set defaults for period stats when no data
      @avg_users_per_period = 0
      @max_users_per_period = 0
      @min_users_per_period = 0
      @avg_queries_per_period = 0
    end
  end

  def prepare_daily_usage_view_vars
    @users = @user_data&.dig('users')&.sort_by { |u| u['query_count'] }&.reverse || []
  end

  def paginate_metrics(metrics, total_days)
    if total_days > DAYS_PER_PAGE
      paginated = Kaminari.paginate_array(metrics).page(params[:page]).per(DAYS_PER_PAGE)
      {
        metrics: paginated,
        use_pagination: true
      }
    else
      {
        metrics: metrics,
        use_pagination: false
      }
    end
  end

  private

  def format_date_range(range)
    start_date = range['start'].is_a?(Date) ? range['start'] : Date.parse(range['start'])
    end_date = range['end'].is_a?(Date) ? range['end'] : Date.parse(range['end'])
    "#{start_date.strftime('%b %d, %Y')} - #{end_date.strftime('%b %d, %Y')}"
  end
end
