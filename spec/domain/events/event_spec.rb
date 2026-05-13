require "rails_helper"

RSpec.describe Events::Event, type: :model do
  subject(:event) do
    described_class.new(
      billetto_id: "test-123",
      title:       "Test Event",
      starts_at:   1.day.from_now
    )
  end

  describe "validations" do
    it "is valid with required attributes" do
      expect(event).to be_valid
    end

    it "requires billetto_id" do
      event.billetto_id = nil
      expect(event).not_to be_valid
    end

    it "requires title" do
      event.title = nil
      expect(event).not_to be_valid
    end

    it "enforces unique billetto_id" do
      event.save!
      duplicate = described_class.new(billetto_id: event.billetto_id, title: "Other")

      expect(duplicate).not_to be_valid
    end
  end

  describe ".listed" do
    it "returns events ordered by starts_at ascending" do
      later  = described_class.create!(billetto_id: "later",  title: "Later",  starts_at: 5.days.from_now)
      sooner = described_class.create!(billetto_id: "sooner", title: "Sooner", starts_at: 1.day.from_now)

      expect(described_class.listed.to_a).to eq([sooner, later])
    end
  end
end