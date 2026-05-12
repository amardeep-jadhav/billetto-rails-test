class VotesController < ApplicationController
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

  private

  # Temporary stub
  def current_user_id
    session[:demo_user_id] ||= "anonymous-#{SecureRandom.hex(4)}"
  end
end