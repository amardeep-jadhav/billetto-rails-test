module Billetto
  module Events
    class EventIngested < RailsEventStore::Event
      SCHEMA = {
        billetto_id:  String,
        title:        String,
        description:  String,
        starts_at:    String,
        ends_at:      String,
        image_url:    String,
        billetto_url: String,
      }.freeze

      def stream_names
        ["BilletEvent$#{data.fetch(:billetto_id)}", "BilletoSync"]
      end
    end
  end
end