require "rails_helper"

RSpec.describe Voting::CastVote do
  let(:event_store) { RailsEventStore::JSONClient.new }
  subject(:service) { described_class.new(event_store: event_store) }

  let(:event_id) { "evt-1" }
  let(:user_id)  { "user-rahul" }

  describe "#call" do
    it "publishes EventUpvoted on first up vote" do
      result = service.call(event_id: event_id, user_id: user_id, direction: "up")

      expect(result).to be_a(Voting::Events::EventUpvoted)
      expect(event_store.read.stream("Event$#{event_id}").count).to eq(1)
    end

    it "publishes EventDownvoted on first down vote" do
      result = service.call(event_id: event_id, user_id: user_id, direction: "down")

      expect(result).to be_a(Voting::Events::EventDownvoted)
    end

    it "publishes EventDownvoted when user flips from up to down" do
      service.call(event_id: event_id, user_id: user_id, direction: "up")
      result = service.call(event_id: event_id, user_id: user_id, direction: "down")

      expect(result).to be_a(Voting::Events::EventDownvoted)
    end

    it "returns nil (toggle-off) when user votes same direction twice" do
      service.call(event_id: event_id, user_id: user_id, direction: "up")
      result = service.call(event_id: event_id, user_id: user_id, direction: "up")

      expect(result).to be_nil
    end

    it "publishes facts to both event and user streams" do
      service.call(event_id: event_id, user_id: user_id, direction: "up")

      expect(event_store.read.stream("Event$#{event_id}").count).to eq(1)
      expect(event_store.read.stream("User$#{user_id}").count).to eq(1)
    end

    it "raises InvalidDirection for unknown direction" do
      expect {
        service.call(event_id: event_id, user_id: user_id, direction: "sideways")
      }.to raise_error(Voting::CastVote::InvalidDirection)
    end
  end
end