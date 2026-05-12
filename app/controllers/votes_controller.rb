class VotesController < ApplicationController
  before_action :require_clerk_session!

  def create
    Voting::CastVote.new.call(
      event_id:  params[:event_id],
      user_id:   current_user_id,
      direction: params[:direction]
    )

    redirect_to events_path
  rescue Voting::CastVote::InvalidDirection
    redirect_to events_path, alert: "Invalid vote direction."
  end
end