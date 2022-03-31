class EventsController < ApplicationController

  def index
    @load_events = Core::LoadEvent.all.order(created_at: :desc)
  end

end
