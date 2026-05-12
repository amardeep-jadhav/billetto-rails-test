class EventsController < ApplicationController
  def index
    @events = Events::Event.order(starts_at: :asc).limit(50)
  end
end