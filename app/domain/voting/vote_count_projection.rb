module Voting
  class VoteCountProjection
    def call(fact)
      ApplicationRecord.transaction do
        record = VoteCount.lock.find_or_initialize_by(event_id: fact.data.fetch(:event_id))

        case fact
        when Voting::Events::EventUpvoted
          apply_upvote(record, fact)
        when Voting::Events::EventDownvoted
          apply_downvote(record, fact)
        end

        record.save!
      end
    end

    private

    def apply_upvote(record, fact)
      previous = previous_direction_for(user_id: fact.data[:user_id], event_id: fact.data[:event_id], before: fact.event_id)

      record.upvotes += 1
      record.downvotes -= 1 if previous == "down"  # they flipped
    end

    def apply_downvote(record, fact)
      previous = previous_direction_for(user_id: fact.data[:user_id], event_id: fact.data[:event_id], before: fact.event_id)

      record.downvotes += 1
      record.upvotes -= 1 if previous == "up"  # they flipped
    end

    def previous_direction_for(user_id:, event_id:, before:)
      facts = Rails.configuration.event_store.read.stream("User$#{user_id}").to_a
      relevant = facts.select { |f| f.data[:event_id] == event_id && f.event_id != before }
      return nil if relevant.empty?

      case relevant.last
      when Voting::Events::EventUpvoted   then "up"
      when Voting::Events::EventDownvoted then "down"
      end
    end
  end
end