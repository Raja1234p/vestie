# Week 5 QA — Stripe config, deposits, payment methods

**App base URL:** `ApiConstants.baseUrl` (currently Azure `/api/v1`; Week 5 doc uses `/api/v1.0` — same paths).

**Tester:** _______________ **Date:** _______________ **Build:** _______________ **Device:** _______________

**Stripe test data:** [stripe_test_cards.md](stripe_test_cards.md)  
**Platform / permissions:** [permissions_and_platform_qa.md](permissions_and_platform_qa.md)  
**API sync:** [api_screen_sync_matrix.md](api_screen_sync_matrix.md)

---

## API integration status (Week 5 doc)

| # | Method | Endpoint | App status | Where / notes |
|---|--------|----------|------------|---------------|
| 0a | POST | `/auth/login` | **Integrated** | Auth (prerequisite) |
| 0b | POST | `/users/me/risk-disclaimer` | **Integrated** | Agreement screen; gate on wallet deposit/withdraw |
| 0b | GET | `/users/me/risk-disclaimer` | **Integrated** | Login/splash/agreement load state |
| 1 | GET | `/stripe/config` | **Integrated** | Deposit + add card (publishable key; cached) |
| 2 | POST | `/stripe/connect/account` | **Not integrated** | Constants only; withdraw uses Week 7 `POST /kyc/start` |
| 3 | POST | `/stripe/connect/accounts/{id}/onboarding-link` | **Not integrated** | — |
| 4 | POST | `/stripe/webhook` | **N/A (server)** | Stripe CLI / Azure Function — not mobile |
| 5 | GET | `/wallet` | **Integrated** | Wallet tab; refresh after deposit success |
| 6 | POST | `/wallet/deposit/intent` | **Integrated** | Body: `{ amount, paymentMethodId }` + `Idempotency-Key` |
| 7 | GET | `/wallet/deposit/{paymentIntentId}/status` | **Integrated** | Poll every 2s, max 90s after PaymentSheet |
| 8 | POST | `/wallet/deposit` (simulated) | **Not in user flow** | Data source exists (`kDebugMode` only); release uses #6–#7 |
| 9 | GET | `/payment-methods` | **Integrated** | Profile + deposit picker |
| 10 | POST | `/payment-methods/setup-intent` | **Integrated** | Add card → PaymentSheet → #11 |
| 11 | POST | `/payment-methods` | **Integrated** | `{ paymentMethodId }` after SetupIntent (SDK path) |
| 11b | POST | `/payment-methods` (raw card) | **Not in UI** | `addCardDev` in data layer; app always uses #10 + SDK |
| 12 | GET | `/payment-methods/{paymentMethodId}` | **Integrated** | Card detail bottom sheet |
| 13 | PATCH | `/payment-methods/{id}/primary` | **Integrated** | `{ isPrimary: true \| false }` — set / unset primary |
| 14 | DELETE | `/payment-methods/{paymentMethodId}` | **Integrated** | Card detail → remove |

**Real-time (optional):** `/hubs/wallet` — client wired; requires Azure WebSockets + live hub (see Week 4 QA known gaps).

---

## Implemented in app (summary)

- `GET /stripe/config`, `GET /wallet`, deposit intent + **PaymentSheet** + status poll
- Deposit UI: amount → **select saved card** → confirm → intent with **`paymentMethodId`**
- Payment methods: list, SetupIntent add card, GET detail, primary/unset, delete
- Risk disclaimer on wallet deposit (payment methods **do not** require disclaimer)

---

## Known gaps (do not fail app for these alone)

| Item | Status |
|------|--------|
| Stripe Connect #2–#3 | **Not in app** — leader payouts / KYC via Week 7 `/kyc/*` |
| Simulated `POST /wallet/deposit` (#8) | Not used in release deposit flow |
| Raw card `POST /payment-methods` (Option B) | Not exposed in UI |
| Transaction history screen | Mock — not Week 5 |
| SignalR `/hubs/wallet` | Wired; often fails if WebSockets off on server |
| Deposit confirm fee row (2.5% UI) | Client preview only — not in Week 5 intent API doc |
| PaymentSheet may re-prompt card | Backend may pre-attach PM from intent; verify on device |

---

## 0. Prerequisites

| # | Test | Steps | Expected | Result |
|---|------|--------|----------|--------|
| 0.1 | Disclaimer accepted | Wallet → Deposit (or Agreement) | Deposit allowed; no 403 | |
| 0.2 | Saved card | Profile → Payment Methods | At least one card for deposit picker | |

---

## 1. Stripe config (`GET /stripe/config`)

| # | Test | Steps | Expected | Result |
|---|------|--------|----------|--------|
| 1.1 | Implicit load | Start deposit or add card | No crash; SDK init from API or fallback `pk_test_…` | |

---

## 2. Payment methods (#9–#14, #10–#11)

**Path:** Profile → **Payment Methods** (manage) or Wallet deposit → **select card**.

| # | Test | Steps | Expected | Result |
|---|------|--------|----------|--------|
| 2.1 | Shimmer | Open Payment Methods | `PaymentCardListShimmer` | |
| 2.2 | List (#9) | After load | Cards from API (brand, last4, primary) | |
| 2.3 | API failure | Offline on open | Empty/error + toast; no mock cards | |
| 2.4 | Add card (#10→#11) | Add Card → Stripe sheet → save | `4242…`; card in list; top success toast | |
| 2.5 | Card detail (#12) | Tap card → sheet | GET detail refreshes preview | |
| 2.6 | Set primary (#13) | Toggle primary ON | Badge; persists after reopen | |
| 2.7 | Unset primary (#13) | Toggle primary OFF | `{ isPrimary: false }`; badge removed | |
| 2.8 | Remove (#14) | Delete non-primary | 204; removed from list | |
| 2.9 | No disclaimer for PM | Logout → add card without disclaimer | Add card works | |
| 2.10 | Deposit picker | Deposit → Continue | Selection list; tap card → confirm | |

---

## 3. Deposit flow (#5–#7)

**Path:** Wallet → **Deposit** → amount → **select card** → **Confirm deposit**.

| # | Test | Steps | Expected | Result |
|---|------|--------|----------|--------|
| 3.1 | Enter amount | e.g. `$50` → Continue | Payment method picker | |
| 3.2 | Select card | Tap saved card | Confirm screen; **From** shows card | |
| 3.3 | Intent body | Confirm (network log) | `POST …/deposit/intent` with `amount` + `paymentMethodId` | |
| 3.4 | PaymentSheet | Confirm deposit | Native Stripe sheet | |
| 3.4a | Success | `4242 4242 4242 4242`, `12/34`, `123` | Poll → success screen | |
| 3.4b | Decline | `4000 0000 0000 0002` | Error toast; balance unchanged | |
| 3.4c | Cancel sheet | Close PaymentSheet | Stay on confirm; no success | |
| 3.5 | Status poll (#7) | After pay | Multiple GET …/status until **Completed** or timeout | |
| 3.6 | Success → Done | Tap Done | Wallet tab; balance updated | |
| 3.7 | Disclaimer | Without disclaimer → deposit | Blocked at gate | |
| 3.8 | No card | Confirm without selecting card | Toast: select payment card | |

---

## 4. End-to-end deposit script

| Step | Action | Expected | Result |
|------|--------|----------|--------|
| 1 | Login | Session OK | |
| 2 | Accept risk disclaimer | POST accepted | |
| 3 | Wallet tab — note balance | Baseline **B0** | |
| 4 | Add/select card if needed | `pm_…` available | |
| 5 | Deposit $50 → pick card → confirm | Intent + PaymentSheet | |
| 6 | Pay `4242…` | Stripe succeeds | |
| 7 | Wait for poll / success | Status **Completed** | |
| 8 | Done → Wallet tab | Balance ≥ **B0 + 50** | |

**Backend:** Webhook must reach API (Stripe CLI locally or Azure relay) or poll stays **Pending**.

---

## 5. Regression

| # | Test | Steps | Expected | Result |
|---|------|--------|----------|--------|
| 5.1 | Contribute | Week 4 $5+ contribute | Still works | |
| 5.2 | Profile / logout | Logout → login | Payment list reloads | |

---

## Week 5 sign-off

| Check | PASS / FAIL |
|-------|-------------|
| Payment methods #9–#14 (+ #10–#11 add card) | |
| Deposit #6–#7 with `paymentMethodId` + wallet refresh | |
| Disclaimer gate on deposit (#0b) | |
| Stripe Connect #2–#3 | N/A mobile (document as not integrated) |

**Notes:**

_______________________________________________

_______________________________________________
