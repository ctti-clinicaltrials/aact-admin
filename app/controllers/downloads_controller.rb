class DownloadsController < ApplicationController
  before_action :set_snapshots_service

  def index
    @latest_snapshots = @snapshots_service.fetch_latest_snapshots

    if @latest_snapshots.nil?
      flash[:alert] = "Failed to fetch latest snapshots."
      @latest_snapshots = []  # Use an empty array instead of an empty hash
    end

    # Add this to debug the response
    Rails.logger.info "Latest snapshots data: #{@latest_snapshots.inspect}"
  end

  private

  def set_snapshots_service
    @snapshots_service = SnapshotsService.new
  end
end