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
| `/profile/completed-projects/detail` | `CompletedProjectDetailScreen` — typed `CompletedProjectDetailRouteArgs` |
| `/profile/key-guidelines` | `KeyGuidelinesScreen` |
| `/profile/my-accounts` | `MyAccountsScreen` (bank accounts) |

## Trace

| Screen | API |
|--------|-----|
| Profile header | `GET /users/me` |
| Transaction history | `GET /wallet/transactions?page=&pageSize=` → `TransactionHistoryCubit` (shimmer, filters client-side, paginated) |
| Completed projects list | `GET /projects/completed?page=&pageSize=` → `CompletedProjectsCubit` (paginated) |
| Completed project detail | `GET /projects/{id}` only — via `ServiceLocator.createCompletedProjectDetailBloc()` (own `ProjectDetailBloc` instance; no pot/borrow/voting side calls) |
| Payment methods entry | `features/payment_methods/` |
| Vestie User Guidelines | `GET /content/user-guidelines` |
| My Accounts entry | `features/bank_accounts/` |

## Completed projects — View

`openCompletedProjectDetail` → `openProjectFromCard` → project detail → `GET /projects/{id}` → `ProjectDetailCompletedVoteOutcomeContent` (real `voting` tallies, amount, and role/category copy).

`SuccessVoteOutcomeScreen` is still used after in-app vote finalize (`successVoteOutcomeRouteArgsFromFinalize`), not from home/profile list **View**.

`CompletedProjectDetailScreen` popup menu (`MemberProjectActionMenu(fundsHistoryOnly: true)`) exposes **only** "Project fund history" — no contribute/borrow/leave actions on a completed project.

## See also

- [`FEATURE_MAP.md`](../../../../FEATURE_MAP.md) Dashboard
- [`lib/features/project_detail/feature_overview.md`](../project_detail/feature_overview.md) — funds history ledger
