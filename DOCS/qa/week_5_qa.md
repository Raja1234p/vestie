# Week 5 QA — Stripe config, deposits, payment methods

**Implemented in app:** `GET /stripe/config`, payment methods list/primary/remove/dev add card, deposit intent + **Stripe PaymentSheet** + poll + confirm screen, disclaimer on deposit.

**Tester:** _______________ **Date:** _______________ **Build:** _______________ **Device:** _______________

**Stripe test data:** [stripe_test_cards.md](stripe_test_cards.md)  
**Platform / permissions:** [permissions_and_platform_qa.md](permissions_and_platform_qa.md)  
**API sync:** [api_screen_sync_matrix.md](api_screen_sync_matrix.md)

---

## Known gaps

| Item | Status |
|------|--------|
| Transaction history screen | Still mock data — not Week 5 API |
| Simulated `POST /wallet/deposit` | Dev-only API helper — **not** used by the app deposit flow |
| `POST /stripe/connect/account` separate flow | Withdraw uses Week 7 `/kyc/*` instead |

---

## 0. Prerequisites

| # | Test | Steps | Expected | Result |
|---|------|--------|----------|--------|
| 0.1 | Disclaimer accepted | Same as Week 4 | Deposit allowed | |
| 0.2 | Wallet funded | Optional: note starting balance | For deposit/withdraw later tests | |

---

## 1. Stripe config (`GET /stripe/config`)

| # | Test | Steps | Expected | Result |
|---|------|--------|----------|--------|
| 1.1 | Implicit load | Start deposit or add card | No crash; Stripe paths work or dev fallback | |

---

## 2. Payment methods (`GET` / `PATCH` / `DELETE` / dev `POST`)

**Path:** Profile → **Payment Methods** (or wallet flow → select payment method).

| # | Test | Steps | Expected | Result |
|---|------|--------|----------|--------|
| 2.1 | Shimmer | Open Payment Methods | `PaymentCardListShimmer`, not centered loader | |
| 2.2 | List | After load | Saved cards from API (brand, last4) | |
| 2.3 | API failure | Force offline on open | May show mock cards + error — document | |
| 2.4 | Set primary | Card detail → set primary | Primary badge updates; persists after reopen | |
| 2.5 | Remove card | Remove non-primary card | Removed from list | |
| 2.6 | Add card (dev) | Add card screen — test/dev path if enabled | New card appears in list | |
| 2.7 | Selection mode | Deposit flow → pick payment method | List opens in selection mode; can pick card or wallet | |

---

## 3. Deposit flow

**Path:** Wallet → **Deposit Funds** → amount → payment method (if shown) → **Confirm**.

| # | Test | Steps | Expected | Result |
|---|------|--------|----------|--------|
| 3.1 | Enter amount | e.g. `$50` → continue | Reaches confirmation | |
| 3.2 | Confirm UI | Review screen | Shows deposit amount | |
| 3.3 | Stripe PaymentSheet opens | Confirm deposit | Native Stripe sheet appears (not instant success) | |
| 3.3a | Success card | Number `4242 4242 4242 4242`, exp `12/34`, CVC `123` | Sheet completes; poll → success | |
| 3.3b | Decline card | `4000 0000 0000 0002`, exp `12/34`, CVC `123` | Error; wallet balance unchanged | |
| 3.3c | Cancel sheet | Tap X / close PaymentSheet | Back to confirm; no success navigation | |
| 3.4 | Success screen | After complete | Success UI; balance updated | |
| 3.5 | Wallet refresh | Wallet tab | Balance increased by deposit amount (match API) | |
| 3.6 | API sync | Note balance B0 → deposit $50 → wallet | Balance ≥ B0 + 50 (see sync matrix) | |
| 3.7 | Disclaimer | Without disclaimer → deposit | Blocked at gate | |
| 3.8 | Production build | Release/profile + **test** backend keys only | PaymentSheet still required; no simulated deposit | |

---

## 4. End-to-end deposit script (from integration plan)

Run in order; check each box.

| Step | Action | Expected | Result |
|------|--------|----------|--------|
| 1 | `POST /auth/login` (via app login) | Session OK | |
| 2 | Accept risk disclaimer | `POST` accepted in app | |
| 3 | Wallet tab — note balance | Baseline recorded | |
| 4 | Deposit $50 via app | Intent created | |
| 5 | Confirm with `4242…` | Payment succeeds | |
| 6 | Wait for poll / success screen | Status **Completed** | |
| 7 | Wallet tab again | Balance ≥ baseline + $50 | |

---

## 5. Regression

| # | Test | Steps | Expected | Result |
|---|------|--------|----------|--------|
| 5.1 | Contribute still works | Week 4 contribute $5+ | Still succeeds | |
| 5.2 | Profile | Open profile, edit optional | No crash | |
| 5.3 | Logout / login | Logout → login | Payment list reloads | |

---

## Week 5 sign-off

| Check | PASS / FAIL |
|-------|-------------|
| Payment methods list + primary/remove | |
| Deposit completes and updates wallet | |
| Shimmer on payment methods | |

**Notes:**

_______________________________________________

_______________________________________________
