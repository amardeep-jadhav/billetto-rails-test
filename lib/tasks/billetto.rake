namespace :billetto do
  desc "Fetch events from Billetto API and publish EventIngested facts"
  task sync: :environment do
    require "rails_event_store"
    Rails.application.eager_load!

    count = Billetto::SyncService.new.call
    puts "Synced #{count} events from Billetto."
  end
end