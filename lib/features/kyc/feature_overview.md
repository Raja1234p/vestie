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

`KycCubit` → `CreateKycSessionUseCase` → `POST /kyc/session` → hosted Stripe Identity UI

## See also

- [`PROJECT_FLOW_MAP.md`](../../../../PROJECT_FLOW_MAP.md) §8 KYC
