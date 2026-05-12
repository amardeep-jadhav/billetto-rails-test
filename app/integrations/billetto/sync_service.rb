module Billetto
  class SyncService
    def initialize(client: Client.new, event_store: Rails.configuration.event_store)
      @client = client
      @event_store = event_store
    end

    def call(per_page: 25, max_pages: 4)
      ingested_count = 0

      max_pages.times do |i|
        page = i + 1
        response = @client.public_events(page: page, per_page: per_page)
        events = response.fetch("data", [])

        events.each do |event_data|
          publish_event_ingested(event_data)
          ingested_count += 1
        end

        break unless response["has_more"]
      end

      ingested_count
    end

    private

    def publish_event_ingested(data)
      fact = Events::EventIngested.new(data: {
        billetto_id:  data.fetch("id").to_s,
        title:        data.fetch("title", "").to_s,
        description:  data.fetch("description", "").to_s,
        starts_at:    data.fetch("startdate", "").to_s,
        ends_at:      data.fetch("enddate", "").to_s,
        image_url:    data.fetch("image_link", "").to_s,
        billetto_url: data.fetch("url", "").to_s,
      })

      primary, *additional = fact.stream_names
      @event_store.publish(fact, stream_name: primary)
      additional.each { |stream| @event_store.link(fact.event_id, stream_name: stream) }
    end
  end
end