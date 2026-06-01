# Stripe keys — Vestie

## Mobile app (Flutter)

- Uses **publishable key** only (`pk_test_…` / `pk_live_…`).
- Configured in `lib/core/constants/stripe_constants.dart` and initialized in `main.dart` via `StripeSdkInitializer`.
- Add card: `POST /payment-methods/setup-intent` → **PaymentSheet** → `POST /payment-methods` with `{ "paymentMethodId": "pm_…" }`.

## Backend (required)

- Store **secret key** in environment only, e.g. `STRIPE_SECRET_KEY=sk_test_…` (never commit to git).
- Secret and publishable keys must be from the **same** Stripe account.
- `GET /stripe/config` should return `{ "publishableKey": "pk_test_…" }`.
- `POST /payment-methods/setup-intent` must create a SetupIntent with the secret key and return `{ "clientSecret": "seti_…_secret_…" }`.

## Test card (test mode)

`4242 4242 4242 4242` — any future expiry, any CVC.

## Security

If a secret key was shared in chat or committed, **rotate it** in the [Stripe Dashboard](https://dashboard.stripe.com/test/apikeys).
