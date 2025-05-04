class DownloadsController < ApplicationController
  before_action :set_snapshots_service

  def index
    @latest_snapshots = @snapshots_service.fetch_latest_snapshots
  end

  def snapshots
    puts "Fetching daily and monthly snapshots with:", params
    @type = params[:type]
    @all_snapshots = @snapshots_service.fetch_all_snapshots_by_type(@type)
    @year = params[:year] || Date.today.year.to_s
    @paginated_daily_snapshots = Kaminari.paginate_array(@all_snapshots[:daily] || []).page(params[:page]).per(10)
  end

  def postgres_instructions
    render 'downloads/instructions/postgres'
  end

  def flatfiles_instructions
    render 'downloads/instructions/flatfiles'
  end

  private

  def set_snapshots_service
    @snapshots_service = SnapshotsService.new
  end
end