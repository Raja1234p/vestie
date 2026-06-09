# Feature: Bank accounts

**Owner folder:** `lib/features/bank_accounts/`

## Purpose

Link, list, set default, and remove bank accounts for withdrawals (Stripe Connect hosted onboarding).

## Architecture (MDC)

| Layer | Key types |
|-------|-----------|
| `data/` | `BankAccountsRemoteDataSource`, `BankAccountsRepositoryImpl` |
| `domain/` | `BankAccountEntity`, `BankAccountsCache`, use cases |
| `presentation/` | `BankAccountsCubit`, `BankBrowserOnboardingRunner`, screens |

**Rules:** No API calls from widgets. Strings → `AppStrings`. Return URLs → `BankFlowConstants` / `ApiConstants.kycReturnUrl`. Browser callback → `vestie://` via `StripeHostedOnboardingLauncher`.

## Dependencies

- `core/stripe/stripe_hosted_onboarding_launcher.dart`
- `core/services/bank_accounts_prefetch.dart`
- `features/kyc/presentation/constants/kyc_flow_constants.dart` (shared `/kyc/complete` return paths)
- `wallet/` withdraw bank picker

## Routes

| Route | Screen | Flow |
|-------|--------|------|
| Profile → My Accounts | `MyAccountsScreen` | `BankBrowserOnboardingRunner` in-place |
| `/bank/link-onboarding` | `BankLinkOnboardingScreen` | Withdraw picker → push → `StripeBrowserOnboardingScreen` |

## API trace

| Action | Endpoint |
|--------|----------|
| Link | `POST /bank-accounts` `{ returnUrl, refreshUrl }` → Stripe URL |
| List | `GET /bank-accounts` |
| Remove | `DELETE /bank-accounts/{id}` |
| Set default | `PATCH /bank-accounts/{id}/default` |

Return: backend `/kyc/complete` → `vestie://kyc/complete` (AASA `/kyc/*`).

## Post-return UX

- Runner returns `BankLinkOnboardingResult.completed` immediately (no API in runner).
- Screen calls `BankAccountsCubit.syncAfterLink()` — no full-page shimmer.
- Toasts: incomplete / canceled via `AppToast` + `AppStrings`.

## See also

- [`DOCS/api_integration_plan.md`](../../../DOCS/api_integration_plan.md) §7.3
- [`lib/features/kyc/feature_overview.md`](../kyc/feature_overview.md)
