class DownloadsController < ApplicationController
  before_action :set_snapshots_service

  def index
    @latest_snapshots = @snapshots_service.fetch_latest_snapshots

    if @latest_snapshots.nil?
      flash[:alert] = "Failed to fetch latest snapshots."
      @latest_snapshots = []  # Use an empty array instead of an empty hash
    end

    Rails.logger.info "Latest snapshots data: #{@latest_snapshots.inspect}"
  end

  def snapshots
    puts "Fetching daily and monthly snapshots with:", params
    @type = params[:type]
    @all_snapshots = @snapshots_service.fetch_all_snapshots_by_type(@type)
    @year = params[:year] || Date.today.year.to_s

    if @all_snapshots.nil?
      flash[:alert] = "Failed to fetch snapshots."
      @all_snapshots = {daily: [], monthly: {}}
    end

    @paginated_daily_snapshots = Kaminari.paginate_array(@all_snapshots[:daily] || [])
                                        .page(params[:page])
                                        .per(10)

    Rails.logger.info "All snapshots data for type #{@type}: #{@all_snapshots.inspect}"
  end

  private

  def set_snapshots_service
    @snapshots_service = SnapshotsService.new
  end
end