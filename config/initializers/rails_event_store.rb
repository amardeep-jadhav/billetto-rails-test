require "rails_event_store"

Rails.configuration.to_prepare do
  Rails.configuration.event_store = RailsEventStore::JSONClient.new

  # Subscriptions will be registered here as we add domain modules
  # e.g., Rails.configuration.event_store.subscribe(Handler, to: [SomeEvent])
end