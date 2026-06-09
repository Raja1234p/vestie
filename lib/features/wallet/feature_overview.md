# Feature: Wallet

**Owner folder:** `lib/features/wallet/`

## Purpose

Wallet tab, deposit (Stripe PaymentSheet), withdraw (preview/submit/poll), recent activity, and transaction amount/confirm flows.

## Architecture (MDC)

| Layer | Key types |
|-------|-----------|
| `data/` | Remote data sources, repository impls, models |
| `domain/` | `WalletEntity`, policies, use cases, `WalletBalanceCache` |
| `presentation/` | Cubits, screens |

**Rules:** `RiskDisclaimerGate` before deposit/withdraw/contribute money paths. Idempotency on deposit/withdraw POSTs. `FailureMapper` for errors. Routes → `AppRoutes` only.

## Dependencies

- `features/kyc/` — withdraw gate
- `features/bank_accounts/` — withdraw bank picker
- `features/payment_methods/` — deposit card picker
- `core/realtime/wallet_signalr_service.dart` — `/hubs/wallet`
- `features/profile/domain/entities/transaction.dart` — activity row model (shared with profile history)

## Routes

| Route | Screen |
|-------|--------|
| Dashboard tab 3 | `WalletScreen` |
| `/wallet/recent-activity` | `WalletRecentActivityScreen` |
| `/wallet/transaction-amount` | Deposit / withdraw amount |
| `/wallet/withdraw-method` | Standard vs instant |
| `/wallet/select-bank` | `SelectBankAccountScreen` |
| `/wallet/transaction-confirm` | Preview + submit |

## API trace

| Flow | Endpoints |
|------|-----------|
| Balances + activity | `GET /wallet` (`recentTransactions[]`) |
| Deposit | `POST /wallet/deposit/intent` → SDK → poll status |
| Withdraw | `POST /wallet/withdrawals/preview`, `POST /wallet/withdrawals`, poll status |

## See also

- [`DOCS/api_integration_plan.md`](../../../DOCS/api_integration_plan.md) Weeks 5 & 7
- [`lib/features/bank_accounts/feature_overview.md`](../bank_accounts/feature_overview.md)
