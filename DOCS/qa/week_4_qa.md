# Week 4 QA — Wallet, contributions, disclaimer, pot

**Implemented in app:** `GET /wallet`, `POST /projects/{id}/contributions`, client fee policy (15%, min $5), wallet tab + contribute flow, `GET /projects/{id}/pot` on project detail, SignalR pot/VFF refresh, risk disclaimer on wallet **and Contribute**.

**Tester:** _______________ **Date:** _______________ **Build:** _______________ **Device:** _______________

**Runbook:** [manual_test_runbook.md](manual_test_runbook.md) · **API sync:** [api_screen_sync_matrix.md](api_screen_sync_matrix.md)

---

## Known gaps (do not fail app for these alone)

| Item | Status |
|------|--------|
| Contribute with card only (no wallet top-up) | API debits **wallet only** — card selection guides user to **Deposit** if balance short |
| Wallet **View all** recent activity | Full list screen may still use mock if API list endpoint not wired |
| SignalR on two devices | Needs two physical devices / accounts on same project |

---

## 0. Prerequisites

| # | Test | Steps | Expected | Result |
|---|------|--------|----------|--------|
| 0.1 | Login | Email/password or Google → dashboard | Lands on Home; no auth loop | |
| 0.2 | Risk disclaimer | New user: open **Wallet** → **Deposit** or **Withdraw** | Agreement / accept prompt | |
| 0.3 | Accept disclaimer | Complete agreement flow | Wallet money flows work without 403 | |
| 0.4 | Shimmer — wallet | Open **Wallet** tab on cold load | `WalletTabShimmer`, not spinner | |

---

## 1. Wallet tab (`GET /wallet`)

| # | Test | Steps | Expected | Result |
|---|------|--------|----------|--------|
| 1.1 | Load balance | Wallet tab | **Wallet Balance** and **Borrowed** show values (not `$—`) | |
| 1.2 | Locked in projects | Wallet tab with `lockedInProjects` > 0 on server | Row **Locked in projects** under main balance | |
| 1.3 | Pull / revisit | Switch away and back | Balance refreshes | |
| 1.4 | API failure | Airplane mode ON → Wallet → OFF → **Try Again** | `AppErrorView` + retry; **no mock balances** | |
| 1.5 | Recent activity | With backend transactions | List from `recentTransactions[]` | |
| 1.5b | Empty activity | No transactions | Empty state | |
| 1.6 | View all | Tap **View all** | Opens recent activity screen | |
| 1.7 | After contribute | Contribute → Wallet tab | Balance decreased by amount + 15% fee | |
| 1.8 | Logout sync | Logout → other user | New user wallet data only | |

---

## 2. Contribute flow (`POST /projects/{id}/contributions`)

**Entry:** Project detail → **Contribute** (active project, no success vote blocking CTAs).

| # | Test | Steps | Expected | Result |
|---|------|--------|----------|--------|
| 2.1 | Disclaimer gate | Without disclaimer → **Contribute** | Same gate as wallet (agreement / accept) | |
| 2.2 | Open flow | Tap Contribute after disclaimer | Amount step; wallet pill if balance covers contribution | |
| 2.3 | Min amount | Enter below $5 → continue | Validation blocks | |
| 2.4 | Fee preview | Enter `$100` → confirm | Fee **15%** ($15); total **$115** | |
| 2.5 | Wallet covers total | Balance ≥ total → wallet selected → confirm | **Confirm** enabled after non-refundable tick | |
| 2.6 | Insufficient wallet — picker | Total > balance → tap payment pill on confirm | **Contribute payment picker**: wallet row **disabled**; cards selectable | |
| 2.7 | Add card from picker | Picker → **Add card** | Add card flow → returns to picker with new card | |
| 2.8 | Card selected, short wallet | Select card → confirm | **Confirm** enabled; submit shows deposit message with shortfall (wallet-only API) | |
| 2.9 | Happy path (wallet) | Sufficient balance → wallet → confirm | Success screen → **Back to Project** | |
| 2.10 | Project detail after success | Return to detail | Raised amount / pot updated (201 + `RefreshProjectPotEvent`) | |
| 2.11 | Contributor count | After contribute (if API returns count on pot) | **N contributors** on project info card when count > 0 | |
| 2.12 | Double tap submit | Tap confirm twice | Single charge (idempotency on server) | |

---

## 3. Risk disclaimer integration

| # | Test | Steps | Expected | Result |
|---|------|--------|----------|--------|
| 3.1 | Wallet deposit | Without disclaimer → **Deposit** | Gated | |
| 3.2 | Wallet withdraw | Without disclaimer → **Withdraw** | Gated | |
| 3.3 | Contribute | Without disclaimer → **Contribute** | Gated | |
| 3.4 | After accept | Deposit / withdraw / contribute | No 403 on wallet/contribute APIs | |

---

## 4. Project pot & SignalR

| # | Test | Steps | Expected | Result |
|---|------|--------|----------|--------|
| 4.1 | Pot on load | Open project detail | Raised amount from `GET /pot` merged into info card | |
| 4.2 | Contributor count | Project with contributors | Label on info card (e.g. `3 contributors`) | |
| 4.3 | Live update (2 users) | User A on detail; User B contributes | A sees pot update without manual reload | |
| 4.4 | VFF badges | Contribution adds VFF | Member rows update after pot refresh | |
| 4.5 | Hub lifecycle | Leave detail | No crash / leak | |

---

## 5. Regression (non-API)

| # | Test | Steps | Expected | Result |
|---|------|--------|----------|--------|
| 5.1 | Home / Discover | Open tabs | Lists load (shimmer → cards) | |
| 5.2 | Project detail | Open project | Detail loads | |
| 5.3 | Navigation | Back from detail | No router error | |

---

## Week 4 sign-off

| Check | PASS / FAIL |
|-------|-------------|
| Wallet loads from API + retry on failure | |
| Locked in projects row (when API sends value) | |
| Contribute min $5 + 15% fee | |
| Disclaimer on wallet + Contribute | |
| Payment picker: wallet disabled when short | |
| Contribute success updates wallet + project pot | |

**Notes:**

_______________________________________________

_______________________________________________
