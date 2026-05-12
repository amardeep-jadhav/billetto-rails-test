require "rails_event_store"

Rails.configuration.to_prepare do
  Rails.configuration.event_store = RailsEventStore::JSONClient.new

  Rails.configuration.event_store.subscribe(
    IngestEventHandler.new,
    to: [Billetto::Events::EventIngested]
  )
end