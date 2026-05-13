require "rails_helper"

RSpec.describe Voting::VoteCountProjection do
  let(:event_store) { Rails.configuration.event_store }
  let(:cast_vote)   { Voting::CastVote.new(event_store: event_store) }
  let(:event_id)    { "evt-projection-1" }

  describe "projection behavior" do
    it "increments upvotes when an EventUpvoted is published" do
      cast_vote.call(event_id: event_id, user_id: "alice", direction: "up")

      count = Voting::VoteCount.find_by(event_id: event_id)
      expect(count.upvotes).to eq(1)
      expect(count.downvotes).to eq(0)
    end

    it "increments downvotes when an EventDownvoted is published" do
      cast_vote.call(event_id: event_id, user_id: "alice", direction: "down")

      count = Voting::VoteCount.find_by(event_id: event_id)
      expect(count.downvotes).to eq(1)
    end

    it "decrements previous counter when a user flips their vote" do
      cast_vote.call(event_id: event_id, user_id: "alice", direction: "up")
      cast_vote.call(event_id: event_id, user_id: "alice", direction: "down")

      count = Voting::VoteCount.find_by(event_id: event_id)
      expect(count.upvotes).to eq(0)
      expect(count.downvotes).to eq(1)
    end

    it "aggregates votes from multiple users" do
      cast_vote.call(event_id: event_id, user_id: "alice", direction: "up")
      cast_vote.call(event_id: event_id, user_id: "bob",   direction: "up")
      cast_vote.call(event_id: event_id, user_id: "carol", direction: "down")

      count = Voting::VoteCount.find_by(event_id: event_id)
      expect(count.upvotes).to eq(2)
      expect(count.downvotes).to eq(1)
      expect(count.score).to eq(1)
    end
  end
end