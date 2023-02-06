class EventsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :catch_not_found
  before_action :set_load_event, only: [:show]
  before_action :is_admin?

  def index
    @load_events = Core::LoadEvent.all.order(created_at: :desc)
  end

  def show
  end

  private
    def set_load_event
      @load_event = Core::LoadEvent.find(params[:id])
    end

    def catch_not_found(e)
      Rails.logger.debug("We had a not found exception.")
      flash.alert = e.to_s
      redirect_to events_path
    end
end
