# Feature: Profile

**Owner folder:** `lib/features/profile/`

## Purpose

Profile tab, edit profile, payment methods entry, transaction history, completed projects, and settings sub-screens.

## Dependencies

- `ProfileRepository`, profile cubits
- `features/payment_methods/` (cards)
- `features/wallet/` — wallet tab + `GET /wallet/transactions` for profile history
- Dashboard tab 4

## Routes

| Route | Screen |
|-------|--------|
| Dashboard tab 4 | `ProfileScreen` |
| `/profile/edit` | Edit profile |
| `/profile/payment-methods` | `PaymentMethodsScreen` |
| `/profile/transaction-history` | `TransactionHistoryScreen` |
| `/profile/completed-projects` | `CompletedProjectsScreen` |
| `/profile/completed-projects/detail` | `SuccessVoteOutcomeLoadScreen` — typed `CompletedProjectDetailRouteArgs` (redirects to full-screen outcome) |
| `/profile/key-guidelines` | `KeyGuidelinesScreen` |
| `/profile/my-accounts` | `MyAccountsScreen` (bank accounts) |

## Trace

| Screen | API |
|--------|-----|
| Profile header | `GET /users/me` |
| Transaction history | `GET /wallet/transactions?page=&pageSize=` → `TransactionHistoryCubit` (shimmer, client-side filters including Upcoming for API type `Upcoming`, paginated) |
| Completed projects list | `GET /projects/completed?page=&pageSize=` → `CompletedProjectsCubit` (paginated) |
| Completed project detail | `GET /projects/{id}` via `SuccessVoteOutcomeLoadScreen` → `SuccessVoteOutcomeScreen` |
| Payment methods entry | `features/payment_methods/` |
| Vestie User Guidelines | `GET /content/user-guidelines` |
| My Accounts entry | `features/bank_accounts/` |
| Delete account | Confirm dialog (Figma) → `GET /account/deletion-eligibility` on **Delete My Account** → `POST /account/delete` if eligible; else `AppToast` + dismiss dialog |

## Completed projects — View

Home / profile **View** on a completed card → `openSuccessVoteOutcomeForCompletedListProject` → `GET /projects/{id}` → `SuccessVoteOutcomeScreen` (back → completed list). **Profile** completed list sets `fromCompletedProjectsList` → CTA **View Details** `pushReplacement` to read-only project detail (`skipCompletedOutcomeTakeover`) — `GET /projects/{id}` only on detail (no `/pot`, no `/closure-voting/active`); back returns to completed list; goal card + read-only members. See `DOCS/qa/api_screen_sync_matrix.md` row **Completed project detail**.

## See also

- [`FEATURE_MAP.md`](../../../../FEATURE_MAP.md) Dashboard
- [`lib/features/project_detail/feature_overview.md`](../project_detail/feature_overview.md) — funds history ledger
