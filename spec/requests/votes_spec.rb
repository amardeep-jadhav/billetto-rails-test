require "rails_helper"

RSpec.describe "Votes", type: :request do
  let!(:event) do
    Events::Event.create!(
      billetto_id: "evt-req-1",
      title:       "Test Event",
      starts_at:   1.day.from_now
    )
  end

  describe "POST /events/:event_id/votes" do
    context "when user is not authenticated" do
      it "redirects to Clerk sign-in" do
        post event_votes_path(event.billetto_id, direction: "up")

        expect(response).to redirect_to(ENV["CLERK_SIGN_IN_URL"])
      end

      it "does not publish a voting fact" do
        expect {
          post event_votes_path(event.billetto_id, direction: "up")
        }.not_to change { Rails.configuration.event_store.read.stream("Event$#{event.billetto_id}").count }
      end
    end

    context "when user is authenticated" do
      before do
        # Stub Clerk session — Clerk::Authenticatable reads from request.env['clerk']
        allow_any_instance_of(ActionDispatch::Request).to receive(:env)
          .and_wrap_original do |original, *args|
            env = original.call(*args)
            env["clerk"] = instance_double(
              "Clerk::Proxy",
              session: { "sid" => "sess_1" },
              user_id: "user_test_123",
              user: nil
            )
            env
          end
      end

      it "publishes a voting fact and redirects" do
        expect {
          post event_votes_path(event.billetto_id, direction: "up")
        }.to change { Rails.configuration.event_store.read.stream("Event$#{event.billetto_id}").count }.by(1)

        expect(response).to redirect_to(events_path)
      end
    end
  end
end