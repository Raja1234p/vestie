# Feature: Profile

**Owner folder:** `lib/features/profile/`

## Purpose

Profile tab, edit profile, payment methods entry, transaction history, completed projects, and settings sub-screens.

## Dependencies

- `ProfileRepository`, profile cubits
- `features/payment_methods/` (cards)
- `features/wallet/` — wallet tab recent activity only (transaction history awaits **dedicated API**)
- Dashboard tab 4

## Routes

| Route | Screen |
|-------|--------|
| Dashboard tab 4 | `ProfileScreen` |
| `/profile/edit` | Edit profile |
| `/profile/payment-methods` | `PaymentMethodsScreen` |
| `/profile/transaction-history` | `TransactionHistoryScreen` |
| `/profile/completed-projects` | `CompletedProjectsScreen` |
| `/profile/my-accounts` | `MyAccountsScreen` (bank accounts) |

## Trace

| Screen | API |
|--------|-----|
| Profile header | `GET /users/me` |
| Transaction history | **Pending** — dedicated ledger/history API (UI uses mock until backend ships) |
| Payment methods entry | `features/payment_methods/` |
| My Accounts entry | `features/bank_accounts/` |

## See also

- [`FEATURE_MAP.md`](../../../../FEATURE_MAP.md) Dashboard
