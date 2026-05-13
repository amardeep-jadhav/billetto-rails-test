# Billetto Rails Test Assignment

Rails app that ingests events from the Billetto API and lets authenticated users
upvote/downvote them. Voting is built on Rails Event Store with DDD-style
bounded contexts.

Built in a day as a take-home assignment.

## Setup

Requires Ruby 3.4, Rails 8, PostgreSQL 16+.

```bash
bundle install
cp .env.example .env   # fill in Billetto + Clerk credentials
bin/rails db:create db:migrate
bin/rails billetto:sync
bin/dev
```

Then open http://localhost:3000.

## Environment variables

See `.env.example`. The non-obvious ones:

- `BILLETTO_API_BASE_URL` — `https://billetto.dk` (host only; path is in the client)
- `BILLETTO_ACCESS_KEY_ID` / `BILLETTO_SECRET_KEY` — generate at billetto.dk → Organiser → Integrate → Developers
- `CLERK_SIGN_IN_URL` — your Clerk hosted sign-in URL
- `CLERK_SECRET_KEY` / `CLERK_PUBLISHABLE_KEY` — from the Clerk dashboard

## Tests

```bash
bundle exec rspec
```

Covers `Events::Event` validations, `Voting::CastVote` decision logic,
`VoteCountProjection` end-to-end through RES, and auth restriction on voting.

## Architecture


app/
├── controllers/        # thin: parse → dispatch → render
├── domain/
│   ├── events/         # Event model
│   └── voting/         # CastVote service, facts, read model, projection
├── integrations/
│   └── billetto/       # ACL: Faraday client + sync service + facts
└── integrators/        # cross-context bridges (EventIngested → events table)
​

**Event sourcing for voting.** Votes are facts in RES, not rows. `vote_counts`
is a projection — derivable by replaying voting facts.

**Dual streams per fact.** Each vote publishes to `Event$<id>` (for the
projection) and `User$<id>` (so `CastVote` can find a user's prior vote
quickly). Streams are basically indexes you declare at write time.

**ACL for Billetto.** Only `app/integrations/billetto/client.rb` knows the
API's auth scheme and JSON shape. Changes there don't leak.

**Thin controllers.** Queries live on domain models (`Events::Event.listed`,
`Voting::VoteCount.for_events`).

## Trade-offs

- **Sign-out is partial.** Clears Clerk's session cookies locally, but Clerk's
  middleware can rehydrate from the refresh token. A full sign-out needs
  Clerk.js client-side — out of scope here.
- **No system test.** Driving Clerk's hosted UI on a separate domain via
  Capybara is more fixture than test in a one-day scope. Request specs cover
  the auth gate.
- **Toggle-off is a no-op** instead of publishing a `VoteRemoved` fact.
- **Sync is manual** via `bin/rails billetto:sync`. Would be cron in production.
- **No pagination, no VCR spec for the Billetto client** — both are
  straightforward follow-ups.