# Feature: KYC

**Owner folder:** `lib/features/kyc/`

## Purpose

Stripe Identity onboarding so users can withdraw and satisfy compliance gates.

## Dependencies

- `KycRepository`, KYC use cases (`inject_wallet.dart`)
- `StripeBrowserOnboardingScreen`
- `app_links` return URLs (`vestie://kyc/*`) — handled outside GoRouter
- `wallet/` (gates withdraw)

## Routes

| Entry | Notes |
|-------|-------|
| Wallet / withdraw gate | Pushes browser onboarding screen |
| Deep link return | `KycReturnUrlOutcome` parsing |

## Trace

`KycBrowserOnboardingRunner` → `POST /kyc/start` → `StripeHostedOnboardingLauncher` → `vestie://kyc/complete` → `GET /kyc/status`

Bank link uses the same HTTPS return pages (`/kyc/complete`, `/kyc/refresh`) via `BankFlowConstants`.

## See also

- [`PROJECT_FLOW_MAP.md`](../../../../PROJECT_FLOW_MAP.md) §8 KYC
