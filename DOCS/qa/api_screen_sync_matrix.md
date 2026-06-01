# API ↔ screen sync matrix

Use this when verifying **data on screen matches API** after actions (refresh, navigate back, pull-to-refresh where available).

**Legend:**  
- **Load** = shimmer/skeleton then API data  
- **Refresh** = automatic after success action  
- **Fallback** = mock/sample + error snackbar if API fails (document on release builds)

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
| Recent activity (full screen) | — | — | **Mock only** (known gap) |
| Contribute amount/confirm | `GET /wallet` (balance), preview client-side | — | — |
| Contribute submit | `POST /projects/{id}/contributions` | — | Wallet tab; project detail reload |
| Project detail | `GET /projects/{id}` | Shimmer | After contribute / announcement |
| Project pot UI | `GET /projects/{id}/pot` | — | **Not wired to UI** |

---

## Week 5 — Stripe & deposits

| Screen | API | Load | Refresh after |
|--------|-----|------|----------------|
| Stripe SDK init | `GET /stripe/config` | On deposit flow | Cached session |
| Payment methods | `GET /payment-methods` | `PaymentCardListShimmer` | Add/remove/primary |
| Deposit confirm | `POST /wallet/deposit/intent` | — | — |
| PaymentSheet | Stripe (`clientSecret`) | — | — |
| Deposit result | `GET /wallet/deposit/{id}/status` poll | Submitting state | Wallet on Completed |
| Wallet after deposit | `GET /wallet` force | — | Balance ↑ |

---

## Week 7 — Withdraw, KYC, banks, comms

| Screen | API | Load | Refresh after |
|--------|-----|------|----------------|
| KYC onboarding | `POST /kyc/start` → WebView | `KycWebViewShimmer` | Withdraw gate |
| KYC gate | `GET /kyc/status` | — | After WebView pop |
| Bank picker | `GET /bank-accounts` | `BankAccountListShimmer` | — |
| Withdraw preview | `POST /wallet/withdrawals/preview` | — | — |
| Withdraw submit | `POST /wallet/withdrawals` + poll | — | Wallet |
| Announcements (detail) | `announcements[]` on `GET /projects/{id}` | With detail | Create/delete → detail reload |
| Notifications | `GET /notifications` | `NotificationListShimmer` | Tap → `POST …/mark-read` |
| FCM | `POST/DELETE …/device-token` | — | Login / logout |

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
