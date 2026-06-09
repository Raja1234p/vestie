# Borrow (member + shared list)

Week 8 Azure API (`ApiConstants.projectBorrowRequests*`).

## Wired
- `GET …/borrow-requests` — project detail tab + full list (`status=Pending`)
- `POST …/vote` — member Agree/Disagree on cards
- `POST …/decide` — GL/Co-Leader approve/reject (replaces `/approve` + `/reject`)
- `GET …/terms` + `POST …/borrow-requests` — borrow amount → confirm → submit (`Idempotency-Key` header; key per confirm session)
- `GET …/mine/screen` + `POST …/cancel` — My Borrow Request screen
- Repay: `GET …/repay` → payment-options → preview → `POST …/repay`
- `GET …/mine/screen` then `GET …/{id}/repay` — My Borrow repay UI when `currentRequest` is null and approved/disbursed row is in `history` (falls back to `GET …/mine` + repay if needed)

## Loading UX
| Action | Pattern |
|--------|---------|
| My Borrow initial load | `MyBorrowRequestShimmer` |
| Borrow requests full list initial load | `BorrowRequestListShimmer` |
| Repay payment-options load | `PaymentCardListShimmer` |
| Borrow amount → terms / confirm submit | `AppButton.isLoading` (`BorrowCubit.loading`) |
| Repay confirm submit | `AppButton.isLoading` (`BorrowRepayConfirmCubit.submitting`) |
| Repay payment row tap (preview POST) | `AppLoadingOverlay` (`selecting`) + disabled rows |
| Member vote Agree/Disagree | `AppVoteButtons.isLoading` (`BorrowVoteCubit.isVoting`) |
| Leader approve/reject | `AppActionDialog.showAsync` on confirm dialog |
| Cancel borrow (dialog) | `AppActionDialog.showAsync` → success dialog after API |
| Repay Borrow Amount (My Borrow) | `AppButton.isLoading` (`startingRepay`) through summary re-check **and** `startRepayFlow` auto-skip |
| My Borrow / repay payment-options load fail | `AppErrorView` + Try Again — not empty state |
| Borrow confirm submit fail | Inline error + `borrowSubmitRetryHint`; Submit retries same idempotency key; back clears key |

## Navigation / sync
- After cancel / submit / approve / reject / repay POST → `BorrowProjectDetailSync.reloadBeforeSuccess` (`GET /projects/{id}` via coordinator) **before** success dialog or screen — includes project pot refresh
- Leader approve/reject on tab or full list → `reloadDetailAndWait` after decide
- My Borrow menu → `pop(true)` after cancel or repay → `refreshAfterBorrowSubmit(reloadDetail: false)` (borrow tab only; detail already synced via `reloadBeforeSuccess`)
- Borrow wallet CTA → same `reloadDetail: false` after submit success pop
- Repay success Done → `BorrowRepayNavigation.finishRepayFlow` (closes success + payment options + my borrow)
- Full borrow list → after member vote, `_reloadRequests()` refreshes all cards’ vote counts (tab preview still updates only the voted card)

## Error feedback (standard for all API features — see `architecture.mdc` §6)
- Load failures (My Borrow, repay payment-options) → `AppErrorView` + Try Again — no toast
- Action failures (submit, cancel, repay, vote, leader decide) → `AppToast.showError`
- Confirm-step submit failure → inline error + `borrowSubmitRetryHint`; toast only on earlier steps

## Layers
`lib/user/features/borrow/` — data/domain/presentation  
Shared entity: `lib/features/project_detail/domain/entities/borrow_request_entity.dart`
