module Voting
  class VoteCount < ApplicationRecord
    self.table_name = "vote_counts"

    validates :event_id, presence: true, uniqueness: true
    validates :upvotes, :downvotes, numericality: { greater_than_or_equal_to: 0 }

    def self.for_events(event_ids)
      where(event_id: event_ids).index_by(&:event_id)
    end

    def total
      upvotes + downvotes
    end

    def score
      upvotes - downvotes
    end
  end
end