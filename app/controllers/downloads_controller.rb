class DownloadsController < ApplicationController
  before_action :set_snapshots_service

  def index
    @latest_snapshots = @snapshots_service.fetch_latest_snapshots # [] as fallback from service
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

    @paginated_daily_snapshots = Kaminari.paginate_array(@all_snapshots[:daily] || []).page(params[:page]).per(5)
  end

  private

  def set_snapshots_service
    @snapshots_service = SnapshotsService.new
  end
end