# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Luum Studio Pilates — a Rails 7.2 API-only backend for a pilates studio management app. It handles class scheduling, reservations, payments (Stripe), push notifications (Expo), and user authentication (JWT + Google OAuth).

## Common Commands

### Docker (recommended)
```bash
docker-compose up -d          # Start all services (Rails, PostgreSQL, Redis, Sidekiq, Stripe CLI)
docker-compose logs -f web    # Tail Rails logs
docker-compose exec web bundle exec rails console
docker-compose exec web bundle exec rspec
```

### Local Development
```bash
bin/setup                           # First-time setup
bundle exec rails db:migrate        # Run migrations
bundle exec rails server -b 0.0.0.0
bundle exec sidekiq                 # Run background workers (separate terminal)
stripe listen --forward-to http://localhost:3000/api/v1/stripe_webhooks  # Stripe webhooks (separate terminal)
```

### Testing
```bash
bundle exec rspec                                    # All tests
bundle exec rspec spec/requests/api/v1/auth_spec.rb  # Single file
bundle exec rspec spec/models/                       # Directory
```

### Sidekiq Web UI
Available at `/sidekiq` — requires admin authentication.

### API Docs
Swagger at `/api-docs` — requires basic auth. Generated via `rswag` from request specs in `spec/requests/`.

## Architecture

### API Structure
All endpoints are namespaced under `/api/v1`. The API is JSON-only (no views). Responses are formatted via **Active Model Serializers** in `app/serializers/api/v1/`. Pagination uses **Kaminari** with metadata (current_page, total_pages, has_next_page, etc.) added by the `Filterable` concern in `app/controllers/concerns/filterable.rb`.

### Authentication
Dual-token JWT system:
- **Access token**: 15-minute expiry, sent as `Bearer` in `Authorization` header
- **Refresh token**: 30-day expiry, stored in `refresh_token_users` table (per device/user_agent/IP)
- Tokens are blacklisted on logout; `BlacklistedToken` and `RefreshTokenUser` cleaned up daily by `CleanupExpiredTokensJob`
- Google OAuth supported via `GoogleIdTokenService`
- All logic in `app/services/jwt_service.rb`

### Authorization
**Pundit** policies in `app/policies/` — every model has a corresponding policy. `ApplicationPolicy` defines defaults. Controllers call `authorize @resource` and `policy_scope(Model)`.

### Service Objects
Business logic lives in `app/services/`, organized by domain:
- `payments/` — Stripe PaymentIntent creation
- `reservations/cancel_service.rb` — cancellation + refund logic
- `class_packages/purchase_with_payment_service.rb` — package purchase flow
- `class_sessions/recurring_creator.rb` — bulk session creation
- `coupons/` — validation and finalization
- `notifications/push_notifications_service.rb` — Expo push
- `filters/` — one filter service per resource, applied via scopes

### Filtering Pattern
Each resource has a corresponding filter service (e.g., `ClassSessionsFilter`). Controllers pass `params` to the filter service, which chains model scopes. The `Filterable` concern handles pagination.

### Payment Flow
1. Client requests payment intent → `PaymentIntentService` creates Stripe `PaymentIntent`
2. Client captures payment on frontend using `client_secret`
3. Stripe webhook hits `POST /api/v1/stripe_webhooks`
4. `StripeWebhooksController` handles `payment_intent.succeeded` → creates reservation or activates package, applies coupon, sends confirmation

### Background Jobs (Sidekiq)
Scheduled via `sidekiq-cron` (`config/sidekiq.yml`):
- `CleanupExpiredTokensJob` — daily at 2 AM
- `CleanupPastClassSessionsJob` — every 15 minutes (deletes started/empty sessions)
- `DeactivePastClassPackagesJob` — daily at 2 AM
- `NotificateClassSessionJob` — enqueued on reservation creation

### Soft Deletes
`ClassSession` uses a `deleted_at` column for soft deletion. Use the `active` scope to exclude deleted records; `deleted` scope to query only deleted ones.

### Key Models
- **User** — roles: `user`, `instructor`, `admin`. Supports Google OAuth (`provider`, `uid`). Has push notification devices, injuries, packages, reservations.
- **ClassSession** — belongs to instructor (User) and lounge. Creates `ClassSpace` records from the lounge's design JSON on creation.
- **Reservation** — books a specific `ClassSpace` in a `ClassSession`. Validates no duplicates, not full. Sends confirmation email.
- **UserClassPackage** — junction between User and ClassPackage tracking `remaining_classes`, status, expiration.
- **Transaction** — polymorphic reference to paid item; Stripe `payment_intent_id`; statuses: `pending`, `succeeded`, `failed`.
- **Coupon** — percentage or fixed discount, global or per-user limits, optional new-user-only targeting.

## Environment Variables

See `.example.env` for the full list. Required variables:
- `DATABASE_URL`, `REDIS_URL`
- `JWT_SECRET`
- `STRIPE_SECRET_KEY`, `STRIPE_PUBLISHABLE_KEY`, `STRIPE_WEBHOOK_SECRET`
- `CLOUDINARY_CLOUD_NAME`, `CLOUDINARY_API_KEY`, `CLOUDINARY_API_SECRET`
- `GOOGLE_CLIENT_ID`
- `BREVO_USERNAME`, `BREVO_SMTP_KEY` (transactional email via Brevo SMTP)
- `RAILS_MASTER_KEY`
- `IS_LOCAL` — set to `true` for local dev (affects Stripe webhook handling)

## Infrastructure

- **Database**: PostgreSQL 15 (port 5433 in Docker)
- **Cache/Queue**: Redis 7 (port 6378 in Docker)
- **Image storage**: Cloudinary (production/development), disk (test)
- **Email**: Brevo SMTP (`user_mailer` for confirmations and password resets)
- **Push notifications**: Expo SDK
- **Payments**: Stripe
