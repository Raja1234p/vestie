# API ↔ screen sync matrix

Use this when verifying **data on screen matches API** after actions (refresh, navigate back, pull-to-refresh where available).

**Legend:**  
- **Load** = shimmer/skeleton then API data  
- **Refresh** = automatic after success action  
- **Load error** = `AppErrorView` + Try Again (no toast); **action error** = `AppToast.showError`

---

## Auth & profile

| Screen | API | Load | Refresh after |
|--------|-----|------|----------------|
| Login | `POST /auth/login` | — | Dashboard |
| Dashboard Home | `GET /projects` (user list) | Shimmer | Tab re-activate / reload flags |
| Discover | `GET /projects` (discover) | Shimmer | Tab re-activate |
| Profile header | `GET /users/me` | Shimmer | Edit profile save |
| Edit profile | `PATCH /users/me`, photo upload | — | Profile tab |
| Risk disclaimer | `GET` + `POST /users/me/risk-disclaimer` | — | Wallet/deposit/withdraw unlock |

---

## Week 4 — Wallet & contributions

| Screen | API | Load | Refresh after |
|--------|-----|------|----------------|
| Wallet tab | `GET /wallet` | `WalletTabShimmer` | Tab open; after deposit/contribute/withdraw |
| Recent activity (wallet) | `recentTransactions[]` from wallet | Part of wallet shimmer | Same as wallet |
| Recent activity (wallet tab) | `recentTransactions[]` from wallet | Part of wallet shimmer | Same as wallet |
| Transaction history (profile) | **Dedicated API (TBD)** | Shimmer then mock | N/A until new endpoint |
| Contribute amount/confirm | `GET /wallet` (balance), preview client-side | — | — |
| Contribute submit | `POST /projects/{id}/contributions` | — | Wallet tab; project detail reload |
| Project detail | `GET /projects/{id}` | Shimmer | After contribute / announcement |
| Project pot UI | `GET /projects/{id}/pot` | — | **Not wired to UI** |
| Project funds history (ledger) | `GET /projects/{projectId}/funds-history` | `ProjectFundsHistoryListShimmer`; load fail → `AppErrorView` + retry | `PaginatedScrollListener` load-more; own Cubit load, independent of parent detail |
| Completed projects list | `GET /projects/completed?page=&pageSize=` | `ProjectCardShimmer` list | `PaginatedScrollListener` load-more |
| Completed project detail | `GET /projects/{id}` only | `ProjectDetailLoadingBody` | Pull-to-refresh; menu limited to Project fund history |

---

## Week 5 — Stripe & deposits

| Screen | API | Load | Refresh after |
|--------|-----|------|----------------|
| Stripe SDK init | `GET /stripe/config` (#1) | On deposit / add card | Session cache |
| Payment methods (manage) | `GET /payment-methods` (#9) | `PaymentCardListShimmer` | Add/remove/primary |
| Card detail sheet | `GET /payment-methods/{id}` (#12) | Inline loader | Toggle/delete |
| Add card | `POST …/setup-intent` (#10) → SDK → `POST /payment-methods` (#11) | Stripe sheet | List refresh |
| Deposit picker | `GET /payment-methods` (#9) | Same as list | After add card |
| Deposit confirm | `POST /wallet/deposit/intent` (#6) `{ amount, paymentMethodId }` | — | — |
| PaymentSheet | Stripe `clientSecret` | — | — |
| Deposit result | `GET /wallet/deposit/{id}/status` (#7) poll | Submitting | Success screen |
| Wallet after deposit | `GET /wallet` (#5) force | — | Done → wallet tab |
| Risk disclaimer | `GET` + `POST /users/me/risk-disclaimer` (#0b) | — | Unlocks deposit |
| Stripe Connect onboarding | `POST /stripe/connect/*` (#2–#3) | — | **Not integrated** |
| Simulated deposit | `POST /wallet/deposit` (#8) | — | **Not in app flow** |
| SignalR wallet hub | `/hubs/wallet` | On wallet tab | Push refresh (if connected) |

---

## Week 7 — Withdraw, KYC, banks, comms

| Screen | API | Load | Refresh after |
|--------|-----|------|----------------|
| KYC onboarding | `POST /kyc/start` → browser | `StripeOnboardingShimmer` | Withdraw gate |
| KYC gate | `GET /kyc/status` | — | After browser onboarding pop |
| Bank picker | `GET /bank-accounts` | `BankAccountListShimmer` | — |
| Withdraw preview | `POST /wallet/withdrawals/preview` | — | — |
| Withdraw submit | `POST /wallet/withdrawals` + poll | — | Wallet |
| Announcements (detail) | `announcements[]` on `GET /projects/{id}` | With detail | Create/delete → detail reload |
| Notifications | `GET /notifications` | `NotificationListShimmer` | Tap → `POST …/mark-read` |
| FCM | `POST/DELETE …/device-token` | — | Login / logout |

---

## Week 8 — Borrow (vacation / emergency)

| Screen | API | Load | Refresh after |
|--------|-----|------|----------------|
| Borrow flow — amount | — (local validation) | — | — |
| Borrow flow — confirm | `GET …/borrow-requests/terms?amount=` | `AppButton.isLoading` on Confirm | — |
| Borrow flow — submit | `POST …/projects/{id}/borrow-requests` | Submit button loading | `reloadBeforeSuccess` → success screen → back to detail (borrow tab only) |
| Project detail — borrow tab | `GET …/borrow-requests?status=Pending` | With project detail shimmer | After vote/decide; `reloadDetailAndWait` |
| Borrow request card (member vote) | `POST …/borrow-requests/{id}/vote` | `AppVoteButtons.isLoading` (`isVoting`) | Vote counts update in card state |
| Borrow request card (leader decide) | `POST …/borrow-requests/{id}/decide` | `AppActionDialog.showAsync` on confirm | `reloadBeforeSuccess` / `reloadDetailAndWait` **before** success dialog |
| Borrow requests full list | `GET …/borrow-requests?status=Pending` | List inline / empty state | Same as tab after decide |
| My Borrow Request | `GET …/borrow-requests/mine/screen` | `MyBorrowRequestShimmer`; load fail → `AppErrorView` + retry | Cancel: POST cancel → `reloadBeforeSuccess` → success dialog → `pop(true)` **only if cancel succeeded** |
| My Borrow (approved/disbursed) | `GET …/mine/screen` then `GET …/{id}/repay` (fallback: `GET …/mine` + repay) | Part of My Borrow load; repay CTA loader through auto-skip | Repay POST → `reloadBeforeSuccess` → success → `finishRepayFlow`; idempotency key stable per confirm Cubit |
| Repay payment options | `GET …/repay/payment-options`; row tap → preview POST | Shimmer on load; load fail → `AppErrorView`; `AppLoadingOverlay` on `selecting` | Preloaded options when auto-skip fell through |
| Repay confirm | `GET …/repay/preview` then `POST …/repay` | Confirm button loading | `WalletBalanceCache.clear()`; success screen |
| Borrow submit confirm | `POST …/borrow-requests` | Footer `AppButton.isLoading` | `Idempotency-Key` header; key created on confirm step; inline error + retry on failure; back clears key |
| Wallet tab (after repay) | `GET /wallet` | — | Next wallet tab open / hub push |

**Notes**

- Borrow list is **not** embedded in `GET /projects/{id}` — `ProjectDetailBloc` fetches pending requests separately when `borrowingEnabled`.
- `MyBorrowRequestArgsBuilder` passes navigation metadata only; all borrow state on that screen comes from `MyBorrowRequestCubit`.
- Pot on detail reloads after leader approve/reject via `reloadDetailAndWait`; explicit post-disburse pot polish may still be needed on member return from repay.

---

## Member profile & moderation (leader / member)

| Screen | API | Load / confirm UX | Refresh after |
|--------|-----|-------------------|---------------|
| Member detail — make / remove co-leader | `POST` / `DELETE …/members/{userId}/co-leader` | `AppActionDialog.showAsync` on confirm | `syncWithProjectDetail` → success dialog → OK |
| Member detail — remove member (footer) | `DELETE …/members/{userId}` | `showRemoveMemberFlow` (`showAsync` + success) | Reload detail if bloc registered → `pop(memberRemoved)` |
| Penalty action — remove / mark defaulted | `POST …/remove-non-repayment`, `POST …/defaulted` | `showRemoveMemberFlow` / `showMarkDefaultedFlow` | `ProjectDetailReloadCoordinator.reload` **before** success dialog |
| Member detail — remove VFF | `DELETE /vff/connections/{userId}` | `showUserVffRemoveConnectionDialog` (`showAsync`) | `syncWithProjectDetail`; footer Following menu unchanged |
| Member detail — send VFF | `POST …/vff-requests` | Footer `AppButton.isLoading` (no dialog) | `syncWithProjectDetail`; chip → Request Sent |
| Leave project warning | `POST …/leave` | `showLeaveProjectConfirmDialog` (`showAsync`) | Success dialog → `HomeProjectListSync` → pop stack |

**Notes**

- Dialog POST actions return `Future<bool>` from Cubit/use case; confirm dialog stays open with primary spinner until POST (+ detail reload when applicable) completes.
- Action failures → `AppToast` via `MemberDetailCubit` listener; confirm dialog remains open for retry.
- Success dialogs are shown **after** `showAsync` returns `true`, matching borrow cancel / leader decide pattern.

---

## Week 10–11 — Closure / success voting

| Screen | API | Load | Refresh after |
|--------|-----|------|----------------|
| Project detail — member cast vote (inline) | `GET /projects/{id}` → `voting`, `votingStatus` | With detail shimmer | `POST …/closure-voting/vote` → tallies from response → `reloadDetailAndWait` → post-vote inline UI |
| Project detail — member post-vote (inline) | Same `voting` + `memberVotes[]` (`voteStatus`: agreed / disagreed / waiting) | With detail shimmer | Pull-to-refresh on normal scroll only; inline post-vote is read-only |
| Project detail — leader View Success Votes | `GET /projects/{id}` → `voting` + `memberVotes[]` (Week 11) | Shimmer on monitor screen | Pull-to-refresh → same single detail call; legacy projects fall back to `GET …/closure-voting/active` |
| Cast vote (routed fallback) | `GET …/closure-voting/active` + `POST …/vote` | Shimmer | `ProjectDetailReloadCoordinator.reload` before success state |

**Notes**

- Member/co-leader inline flow uses **`GET /projects/{id}` only** on detail load when Week 11 `voting` is present — skips redundant `GET active` probe.
- `hasVoted: true` plus viewer row in `memberVotes[]` drives post-vote banner; counts must match `memberVotes` tallies.
- Action failure on cast → `AppToast.showError`; submit uses `AppVoteButtons` / `isLoading` on inline cast.

---

## Sync test procedure (per screen)

For each **money** screen row above:

1. Note value on screen (e.g. wallet balance **B**).  
2. Perform action (deposit, contribute, withdraw).  
3. Return to screen without killing app.  
4. Confirm value updated to **B′** matching API (or admin panel).  
5. Kill app → cold start → login → confirm still correct.  
6. Logout → login as same user → confirm still correct.

| Screen tested | B → B′ correct | Cold start | Re-login | Result |
|---------------|----------------|------------|----------|--------|
| Wallet | | | | |
| Project detail (after contribute) | | | | |
| Project detail (after borrow approve) | | | | |
| My Borrow Request (after submit / cancel) | | | | |
| Wallet (after borrow repay) | | | | |
| Payment methods | | | | |
| Notifications unread | | | | |

---

## Fallback behavior (release audit)

| Screen | On API failure | Release expectation |
|--------|----------------|---------------------|
| Wallet | Mock balances + error | Prefer empty/error only for store |
| Payment methods | Mock cards + error | Same |
| Notifications | Sample list + error | Same |
| Home/Discover | Error state | No mock projects |

Document any **FAIL** where UI shows mock data without clear error.
