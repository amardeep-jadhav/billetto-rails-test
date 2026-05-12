class EventsController < ApplicationController
  def index
    @events = Events::Event.listed
    @vote_counts = Voting::VoteCount.for_events(@events.map(&:billetto_id))
  end
end