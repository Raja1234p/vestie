# Network prefetch — duplicate-request prevention

Vestie warms caches on tab activation (Home / Dashboard) without duplicate in-flight API calls.

## Pattern

Each prefetch helper uses:

1. **Cache short-circuit** — return immediately when domain cache is populated (`WalletBalanceCache`, `PaymentMethodsCache`, `BankAccountsCache`).
2. **`_inFlight` guard** — concurrent `warmIfNeeded()` calls share one `Future`.
3. **`refresh()`** — explicit `forceRefresh: true` for silent background updates after mutations.

## Implementations

| Service | File | Cache |
|---------|------|-------|
| Wallet | `lib/core/services/wallet_prefetch.dart` | `WalletBalanceCache` |
| Payment methods | `lib/core/services/payment_methods_prefetch.dart` | `PaymentMethodsCache` |
| Bank accounts | `lib/core/services/bank_accounts_prefetch.dart` | `BankAccountsCache` |

Repositories also return cached data when `forceRefresh` is false.

## UI integration

`HomeScreen._onTabActivated()` calls all three `warmIfNeeded()` helpers in parallel via `unawaited()`. No behavior change — only avoids redundant network when cache is warm or a prefetch is already running.
