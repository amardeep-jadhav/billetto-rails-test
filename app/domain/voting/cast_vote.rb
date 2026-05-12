module Voting
  class CastVote
    class InvalidDirection < StandardError; end

    UP   = "up".freeze
    DOWN = "down".freeze
    VALID_DIRECTIONS = [UP, DOWN].freeze

    def initialize(event_store: Rails.configuration.event_store)
      @event_store = event_store
    end

    def call(event_id:, user_id:, direction:)
      raise InvalidDirection, "direction must be 'up' or 'down'" unless VALID_DIRECTIONS.include?(direction)

      previous = previous_vote_for(user_id: user_id, event_id: event_id)

      fact = build_fact(event_id: event_id, user_id: user_id, direction: direction, previous: previous)
      return nil if fact.nil?  # toggle-off (clicked same direction again)

      publish(fact)
      fact
    end

    private

    def previous_vote_for(user_id:, event_id:)
      facts = @event_store.read.stream("User$#{user_id}").to_a
      relevant = facts.select { |f| f.data[:event_id] == event_id }
      return nil if relevant.empty?

      case relevant.last
      when Voting::Events::EventUpvoted   then UP
      when Voting::Events::EventDownvoted then DOWN
      end
    end

    def build_fact(event_id:, user_id:, direction:, previous:)
      return nil if previous == direction  # toggle-off — no new fact (out of scope)

      klass = direction == UP ? Voting::Events::EventUpvoted : Voting::Events::EventDownvoted
      klass.new(data: { event_id: event_id, user_id: user_id })
    end

    def publish(fact)
      primary, *additional = fact.stream_names
      @event_store.publish(fact, stream_name: primary)
      additional.each { |stream| @event_store.link(fact.event_id, stream_name: stream) }
    end
  end
end