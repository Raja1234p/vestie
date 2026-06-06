# Feature: Profile

**Owner folder:** `lib/features/profile/`

## Purpose

Profile tab, edit profile, payment methods entry, transaction history, completed projects, and settings sub-screens.

## Dependencies

- `ProfileRepository`, profile cubits
- `features/payment_methods/` (cards)
- Dashboard tab 4

## Routes

| Route | Screen |
|-------|--------|
| Dashboard tab 4 | `ProfileScreen` |
| `/profile/edit` | Edit profile |
| `/profile/payment-methods` | `PaymentMethodsScreen` |
| `/profile/transactions` | `TransactionHistoryScreen` |
| `/profile/completed-projects` | `CompletedProjectsScreen` |

## Trace

`ProfileScreen` → profile cubit → `GET /users/me`

## See also

- [`FEATURE_MAP.md`](../../../../FEATURE_MAP.md) Dashboard
