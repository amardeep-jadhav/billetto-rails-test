require "vcr"

VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!

  config.filter_sensitive_data("<BILLETTO_ACCESS_KEY_ID>") { ENV["BILLETTO_ACCESS_KEY_ID"] }
  config.filter_sensitive_data("<BILLETTO_SECRET_KEY>") { ENV["BILLETTO_SECRET_KEY"] }
end