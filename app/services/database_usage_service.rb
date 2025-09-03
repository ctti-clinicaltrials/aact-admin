class DatabaseUsageService
  include Cacheable

  CACHE_DATABASE_USAGE_PREFIX = "database_usage/"
  CACHE_DAILY_USER_USAGE_PREFIX = "daily_user_usage/"
  PGBADGER_DATE_FORMAT = '%Y-%m-%d'
  PGBADGER_FILE_EXTENSION = '.html'

  def initialize(api_client = AactApiClient.new)
    @api_client = api_client
  end

  def fetch_dashboard_data(start_date_param, end_date_param)
    start_date = Date.parse(start_date_param)
    end_date = Date.parse(end_date_param)

    cache_key = "#{CACHE_DATABASE_USAGE_PREFIX}#{start_date}_#{end_date}"

    usage_data = fetch_with_cache(cache_key) do
      @api_client.get_database_usage(
        start_date: start_date,
        end_date: end_date
      )
    end

    {
      usage_data: usage_data,
      dates: { start_date: start_date, end_date: end_date },
      total_days: (end_date - start_date).to_i + 1
    }
  end

  def fetch_daily_usage(date_param)
    date = Date.parse(date_param)
    cache_key = "#{CACHE_DAILY_USER_USAGE_PREFIX}#{date.strftime(PGBADGER_DATE_FORMAT)}"

    user_data = fetch_with_cache(cache_key) do
      @api_client.get_user_usage(start_date: date.to_s, end_date: date.to_s)
    end

    {
      user_data: user_data,
      date: date,
      formatted_date: date.strftime('%B %d, %Y'),
      stats: calculate_user_stats(user_data&.dig('users') || []),
      pgbadger_url: generate_pgbadger_url(date)
    }
  end

  private

  def calculate_user_stats(users)
    return default_stats if users.blank?

    {
      total_users: users.size,
      total_queries: users.sum { |u| u['query_count'] },
      total_duration: users.sum { |u| u['total_duration_ms'].to_f },
      avg_queries_per_user: users.size > 0 ? (users.sum { |u| u['query_count'] }.to_f / users.size) : 0
    }
  end

  def default_stats
    {
      total_users: 0,
      total_queries: 0,
      total_duration: 0,
      avg_queries_per_user: 0
    }
  end

  def generate_pgbadger_url(date)
    base_url = ENV.fetch('BASE_PGBADGER_URL') {
      raise "BASE_PGBADGER_URL environment variable is required"
    }
    filename = "#{date.strftime(PGBADGER_DATE_FORMAT)}#{PGBADGER_FILE_EXTENSION}"
    return "#{base_url}/#{filename}"
  end
end
