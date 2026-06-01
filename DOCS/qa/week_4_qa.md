# Week 4 QA — Wallet, contributions, disclaimer

**Implemented in app:** `GET /wallet`, `POST /projects/{id}/contributions`, client fee policy (15%, min $5), wallet tab + contribute flow, disclaimer gate on wallet flows.

**Tester:** _______________ **Date:** _______________ **Build:** _______________ **Device:** _______________

**Runbook:** [manual_test_runbook.md](manual_test_runbook.md) · **API sync:** [api_screen_sync_matrix.md](api_screen_sync_matrix.md)

---

## Known gaps (do not fail app for these alone)

| Item | Status |
|------|--------|
| `GET /projects/{id}/pot` on project detail UI | Data layer only — pot not shown on detail screen yet |
| Recent activity on wallet | From `GET /wallet` `recentTransactions[]`; falls back to mock list if API fails |
| SignalR live pot updates | Not in mobile scope |

---

## 0. Prerequisites

| # | Test | Steps | Expected | Result |
|---|------|--------|----------|--------|
| 0.1 | Login | Email/password or Google → dashboard | Lands on Home; no auth loop | |
| 0.2 | Risk disclaimer | New user or cleared disclaimer: open **Wallet** → **Deposit** or **Withdraw** | Redirected to agreement OR prompted to accept | |
| 0.3 | Accept disclaimer | Complete agreement flow | Can open wallet deposit/withdraw without 403 snackbar | |
| 0.4 | Shimmer — wallet | Open **Wallet** tab on cold load | `WalletTabShimmer` (balance + buttons + activity skeleton), not spinner | |

---

## 1. Wallet tab (`GET /wallet`)

| # | Test | Steps | Expected | Result |
|---|------|--------|----------|--------|
| 1.1 | Load balance | Wallet tab | **Wallet Balance** and **Borrowed** show numeric values (not `$—`) | |
| 1.2 | Pull / revisit | Switch away and back to Wallet tab | Balance refreshes; no duplicate error spam | |
| 1.3 | API failure fallback | Airplane mode ON → open Wallet → OFF → retry | Error snackbar once; may show fallback amounts (mock) — document behavior | |
| 1.4 | Recent activity | With backend transactions | List shows titles/amounts from API | |
| 1.4b | Empty activity | Account with no transactions | Empty state (not crash) | |
| 1.5 | View all | Tap **View all** on recent activity | Opens recent activity screen | |
| 1.6 | API sync | Deposit/contribute then return to Wallet | Balance matches server within ~2 poll cycles | |
| 1.7 | Logout sync | Logout → login as different user | Wallet shows new user data, not cached old balance | |

---

## 2. Contribute flow (`POST /projects/{id}/contributions`)

**Entry:** Project detail → **Contribute** (member on active project).

| # | Test | Steps | Expected | Result |
|---|------|--------|----------|--------|
| 2.1 | Open flow | Tap Contribute | Amount / confirm UI loads; wallet balance visible if applicable | |
| 2.2 | Min amount | Enter `$4` or below $5 → continue | Blocked with validation (min $5) | |
| 2.3 | Fee preview | Enter `$100` | Platform fee **15%** ($15); total debited **$115** on confirm | |
| 2.4 | Insufficient balance | Amount + fee > wallet balance → submit | Error message (400 / friendly copy) | |
| 2.5 | Happy path | Valid amount, sufficient wallet → confirm | Success; returns to project or success UI | |
| 2.6 | Wallet after contribute | Wallet tab | Available balance decreased by total debited | |
| 2.7 | Double tap submit | Tap confirm twice quickly | No double charge; idempotent behavior on server | |
| 2.8 | Disclaimer gate | Log out, login without disclaimer, try contribute | Gated or error until disclaimer accepted | |

---

## 3. Risk disclaimer integration

| # | Test | Steps | Expected | Result |
|---|------|--------|----------|--------|
| 3.1 | Wallet deposit gate | Without disclaimer → **Deposit Funds** | Agreement flow or block | |
| 3.2 | Wallet withdraw gate | Without disclaimer → **Withdraw Funds** | Agreement flow or block | |
| 3.3 | After accept | Deposit/withdraw allowed | No 403 on wallet APIs | |

---

## 4. Regression (non-API)

| # | Test | Steps | Expected | Result |
|---|------|--------|----------|--------|
| 4.1 | Home / Discover | Open tabs | Project lists load (shimmer then cards) | |
| 4.2 | Project detail | Open any project | Detail loads (shimmer then content) | |
| 4.3 | Navigation | Back from project detail | No black screen / router error | |

---

## Week 4 sign-off

| Check | PASS / FAIL |
|-------|-------------|
| Wallet loads from API | |
| Contribute min $5 + 15% fee | |
| Contribute success updates wallet | |
| Disclaimer gates wallet money flows | |

**Notes:**

_______________________________________________

_______________________________________________
