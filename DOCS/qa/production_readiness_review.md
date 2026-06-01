# Vestie API integration — production readiness review (final)

**Review date:** 2026-05-29 (reverified)  
**Scope:** Mobile app Weeks **4**, **5**, **7** vs Vestie backend API docs  
**Goal:** Ship money flows without breaking existing Vestie navigation and screens.

### Build verification (2026-05-29)

| Check | Result |
|-------|--------|
| `flutter analyze` | **0 errors** (8 info-level lints only) |
| `flutter build apk --debug` | **Success** (`app-debug.apk`) |
| Analyzer warnings (unused `initial`, borrow import) | **Fixed** |

---

## Executive summary

| Week | Production-ready? | Summary |
|------|-------------------|---------|
| **Week 4** | **Mostly yes** | Wallet + contribute match API rules (15% fee, $5 min, idempotency). Pot/VFF on detail and SignalR are **not** in the app. |
| **Week 5** | **Mostly yes** | Payment methods API + **Stripe PaymentSheet** on deposit (intent → sheet → poll). Simulated `POST /wallet/deposit` is not used in-app. |
| **Week 7** | **Partial** | Withdraw + KYC + announcements + FCM + **mark-read on tap** are wired; **link bank in-app** remains the main UX gap. |

**Existing flows (Home, Discover, project detail, VFF, create project, profile):** No intentional router or bloc rewrites in those areas. API work is additive with **mock fallbacks** on failure so tabs do not go blank — acceptable for soft launch; tighten for strict production.

**Base URL (important):** The app uses:

`https://vestie-backend-byexejcapyhaapfy.centralus-01.azurewebsites.net/api/v1`

Your PDFs reference `https://api.vestie.app/api/v1.0`. Paths are the same (`/wallet`, `/projects/.../contributions`, etc.). Backend notes **v1 and v1.0 both work** on the same host. Before store release, confirm with backend which host is production and update `ApiConstants.baseUrl` only when product approves (today it is **unchanged** per integration plan).

---

## Cross-cutting production checklist

| Item | Status | Notes |
|------|--------|--------|
| Auth Bearer on protected routes | Ready | Existing `BaseApiClient` |
| Risk disclaimer before wallet/deposit/withdraw/KYC/bank | Ready | `RiskDisclaimerGate` on wallet flows; API 403 → `ForbiddenFailure` + snackbar patterns |
| Idempotency-Key on contribute, deposit intent, withdraw | Ready | `core/utils/idempotency_key.dart` |
| Failure → user message | Ready | `FailureMapper` + `AppSnackBar` |
| Logout cache invalidation | Ready | Wallet, payments, Stripe, KYC, bank, FCM unregister |
| Shimmer on API screens | Ready | Wallet, notifications, payment methods, bank picker, KYC load |
| Mock fallback on API failure | Caution | Wallet, notifications, payment methods show samples + error — **disable or gate for strict prod** |
| Permissions (camera, photos, notifications) | Ready | `AppPermissionHelper` + manifest/plist; denied → snackbar or **Open Settings** — QA: [permissions_and_platform_qa.md](permissions_and_platform_qa.md) |
| Stripe PaymentSheet (production deposit) | Ready | No simulated deposit in app; QA: [stripe_test_cards.md](stripe_test_cards.md) |
| API screen sync audit | Ready | Matrix: [api_screen_sync_matrix.md](api_screen_sync_matrix.md) |
| Manual QA runbook | Ready | [manual_test_runbook.md](manual_test_runbook.md) |
| SignalR `contribution_made` / `pot_updated` | Not implemented | Optional Week 4; poll/refresh on navigate instead |

---

# Week 4 — Contributions & accounting

## API alignment

| # | Endpoint | App | Production |
|---|----------|-----|------------|
| 1 | `GET /wallet` | `WalletCubit` → `WalletModel` | **Ready** — `availableBalance`, `borrowedBalance`, `lockedInProjects`, `pendingWithdrawal`, `recentTransactions` parsed |
| 2 | `POST /projects/{id}/contributions` | `ContributionRemoteDataSource` + `ContributeBloc` | **Ready** — body `{ amount }`, idempotency header, wallet refresh after success |
| 3 | `GET /projects/{id}/pot` | `GetProjectPotUseCase` + repository | **Not in UI** — data layer only; detail still uses `GET /projects/{id}` for members, not pot endpoint |

## Business rules vs app

| Rule | API | App |
|------|-----|-----|
| Platform fee 15% | Server calculates on POST | Client preview via `ContributionFeePolicy` (15%) — must match server |
| Min $5 | 400 if below | `ContributionFeePolicy.validateAmount` |
| Total debited = amount + fee | Response fields | Shown on confirm step |
| Wallet balance ≥ amount + fee | 400 | Client can pre-check via `GET /wallet` in contribute init |
| VFF after contribution | `vffMemberUserIds` in 201 response | **Not verified** on member badges from response — detail refresh relies on `LoadProjectDetailEvent` |
| Double-entry / idempotency | Server | Client sends `Idempotency-Key` |

## UI / flows

| Screen | Ready? | Notes |
|--------|--------|--------|
| Wallet tab | Yes | Shimmer → balances; pending withdrawal banner (W7 field) |
| Recent activity | Yes | From `recentTransactions[]`; mock fallback if `GET /wallet` fails |
| Contribute flow | Yes | Wallet-only debit (correct for Week 4 API); payment card UI is legacy picker — does not POST card to contributions |
| Locked balance row | Partial | Parsed in model; **not shown** on `WalletOverviewCard` (only balance + borrowed) |
| Project detail pot / VFF from `GET /pot` | No | Not wired |

## Week 4 — blockers before strict production

1. **Optional:** Wire `GET /projects/{id}/pot` on project detail (pot amount, contributor count, VFF badges).  
2. **Optional:** SignalR for live pot (not required if pull-to-refresh is enough).  
3. **QA:** Confirm 201 response fee/total match confirm screen (15%).  
4. **Config:** Confirm production base URL with backend.

## Week 4 — regression (must not break)

- Home / Discover project lists  
- Project detail load (`ProjectDetailBloc`)  
- Join requests, member detail, create project wizard  
- Navigation / `go_router` paths unchanged for non-wallet features  

**Verdict:** **Shippable** for wallet + contribute if backend is Azure host and QA passes [week_4_qa.md](week_4_qa.md). Not a full accounting/pot/VFF parity with API doc.

---

# Week 5 — Stripe, deposits, payment methods

## API alignment

| # | Endpoint | App | Production |
|---|----------|-----|------------|
| 0b | `POST /users/me/risk-disclaimer` | Agreement flow | **Ready** |
| 1 | `GET /stripe/config` | `GetStripeConfigUseCase` + cache | **Ready** (used in stack) |
| 2–3 | Stripe Connect account / onboarding link | Constants exist; withdraw uses **W7 `/kyc/start`** | N/A for W5-only |
| 5 | `GET /wallet` | Shared with W4 | **Ready** |
| 6 | `POST /wallet/deposit/intent` | `WalletDepositRemoteDataSource` | **Ready** + idempotency |
| 7 | `GET /wallet/deposit/{pi}/status` | Poll in repository | **Ready** |
| 8 | `POST /wallet/deposit` (simulated) | `kDebugMode` only | **Dev/QA only** — correct |
| 9–14 | Payment methods CRUD | `PaymentMethodsCubit` + remote DS | **Ready** — list, get, patch primary, delete |
| 10–11 | SetupIntent + save `paymentMethodId` | Data layer `createSetupIntent` + attach | **Not in add-card UI** — add card uses **raw card fields** (API Option B, testing) |

## Critical gap: Stripe PaymentSheet

| Expected (API doc) | Current app |
|--------------------|-------------|
| `POST /deposit/intent` → `clientSecret` → **Stripe SDK confirm** → webhook → poll #7 | Intent created → **no `flutter_stripe`** → if empty `clientSecret` or debug, **`POST /wallet/deposit` simulated** or poll only |

**Production impact:** Testers on **release builds** without simulated endpoint may see deposit **stuck Pending** or **timeout** unless PaymentSheet is integrated.

**Recommendation before production:**

1. Add `flutter_stripe`, init with `GET /stripe/config` publishable key.  
2. On confirm deposit: present PaymentSheet with `clientSecret`, then poll #7.  
3. Keep simulated deposit **only** `kDebugMode` / dev flavor.

## Payment methods

| Feature | Ready? |
|---------|--------|
| List cards | Yes + shimmer |
| Set primary / remove | Yes |
| Add card (raw fields) | Yes for **QA**; production should use SetupIntent (#10 → #11) |
| Selection mode for deposit | UI exists; deposit flow does not require card today |

## Week 5 — blockers before strict production

1. **Stripe PaymentSheet** for real deposits (blocker for real money in).  
2. **Add card via SetupIntent** for PCI/production policy (blocker if raw PAN is forbidden).  
3. Transaction history screen still **mock** — out of W5 scope unless API exists elsewhere.

## Week 5 — regression

- Contribute (Week 4) still works  
- Profile / edit profile  
- Wallet withdraw (Week 7) independent path  

**Verdict:** **Not fully production-ready for real card deposits** until PaymentSheet ships. **Payment methods list/manage** is production-ready against API. QA: [week_5_qa.md](week_5_qa.md).

---

# Week 7 — Withdrawals, KYC, banks, announcements, notifications, FCM

## API alignment

| # | Endpoint | App | Production |
|---|----------|-----|------------|
| 1 | `POST /wallet/withdrawals/preview` | `PreviewWithdrawalUseCase` | **Ready** — Standard / Instant |
| 2 | `POST /wallet/withdrawals` | `RunWalletWithdrawUseCase` + idempotency | **Ready** |
| 3 | `GET /wallet/withdrawals/{id}` | Poll in repository | **Ready** |
| 4 | `POST /kyc/start` | `KycOnboardingScreen` WebView | **Ready** — `returnUrl` / `refreshUrl` `https://vestie.app/kyc/...` |
| 5 | `GET /kyc/status` | Withdraw gate | **Ready** — `canWithdraw` = Verified + payoutsEnabled |
| 6 | `POST /bank-accounts` | Remote DS `link()` only | **No UI / no use case** |
| 7 | `GET /bank-accounts` | List + select screen | **Ready** |
| 8 | `DELETE /bank-accounts/{id}` | `RemoveBankAccountUseCase` | **Ready** in data layer; **no profile settings UI** |
| * | `GET /wallet` (pending + txs) | Wallet tab | **Ready** |
| 9 | `GET /projects/{id}` announcements | Parsed `announcements[]` | **Ready** |
| 10–11 | Create / delete announcement | Create screen + swipe delete | **Ready** |
| 12–13 | FCM device token | `FcmPushService` register/unregister | **Ready** (needs Firebase files + device) |
| 14 | `GET /notifications` | `NotificationsCubit` | **Ready** + shimmer |
| 15 | `POST /notifications/mark-read` | `NotificationsCubit.markAsRead` on tile tap | **Ready** (skipped when list uses fallback samples) |

## Withdraw business rules

| Rule | App |
|------|-----|
| Min $10 | `wallet_withdraw_validation.dart` + API 400 |
| Standard fee 0% | Preview from API |
| Instant fee 1.5% | Preview from API |
| KYC Verified + bank + balance | Gate on withdraw method screen |

## Week 7 — blockers before strict production

1. **Link bank (`POST /bank-accounts`)** — users need banks linked via backend/Stripe dashboard or new in-app flow (token or onboarding URL).  
2. **Bank remove UI** — optional settings screen for #8.  
4. FCM: verify token on prod backend; push delivery is ops + Apple/Google certs.

## Week 7 — regression

- Deposit and contribute unchanged  
- Project detail announcements replace old single “description as announcement” for **list**; empty state placeholder unchanged  
- Leader create announcement → refresh detail (existing bloc)  

**Verdict:** **Shippable** for withdraw/KYC/announcements/FCM register when users already have linked banks. **Not self-contained** for new users without bank link UI. QA: [week_7_qa.md](week_7_qa.md).

---

# Production go / no-go matrix

| Capability | Go? | Condition |
|------------|-----|-----------|
| Login / dashboard / projects | **Go** | Unchanged paths |
| Risk disclaimer gating | **Go** | QA 0b |
| Wallet balances | **Go** | QA W4-1 |
| Contribute ($5+, 15%) | **Go** | QA W4-2 + API fee match |
| Payment methods manage | **Go** | QA W5-2 |
| Deposit (real card) | **Go** | PaymentSheet + poll; QA with Stripe test cards |
| Withdraw Standard/Instant | **Go** | If KYC + bank pre-linked |
| KYC WebView | **Go** | QA W7-1 |
| Link bank in app | **No-go** | Needs UI + use case |
| Announcements | **Go** | QA W5-7 |
| Notifications list + mark-read | **Go** | Tap marks read via API (not when fallback samples) |
| FCM token lifecycle | **Go** | Verify on server |

---

# Recommended pre-release actions (priority)

### P0 — must fix for real money

1. Confirm **`ApiConstants.baseUrl`** with backend (Azure vs `api.vestie.app`).  
2. Run full E2E deposit with Stripe test cards ([week_5_qa.md](week_5_qa.md)).  
3. Run full E2E scripts in [week_4_qa.md](week_4_qa.md), [week_7_qa.md](week_7_qa.md).

### P1 — should fix for complete Week 7 UX

4. **Link bank** screen (`POST /bank-accounts` with token or onboarding URL).  
5. Remove or flavor-gate **mock fallbacks** on release builds.

### P2 — parity with API doc (can follow release)

7. Wire **`GET /projects/{id}/pot`** on project detail.  
8. Add card via **SetupIntent** instead of raw PAN.  
9. Show **locked in projects** on wallet if product wants it.  
10. SignalR optional.  
11. Transaction history from API when endpoint exists.

---

# Existing flow safety statement

These areas were **not** replaced by API modules; they should behave as before:

- Authentication, onboarding, splash  
- Home / Discover (`HomeBloc`, `DiscoverCubit`)  
- Project detail layouts (member / leader / investment) except **announcements list** now uses `announcements[]`  
- VFF hub, join requests, member detail  
- Create project wizard, profile edit, completed projects list  
- Borrow / repay flows (separate from Week 7 withdraw to bank)  

**Caveats:**

- Wallet tab now calls real API (with fallback) instead of static mock only.  
- Notifications call real API (with fallback).  
- Payment methods call real API (with fallback).  

If API is down, users may see **sample data + error snackbar** rather than empty screens — by design.

---

# Sign-off

| Role | Name | Date | Week 4 | Week 5 | Week 7 |
|------|------|------|--------|--------|--------|
| Mobile dev | | | | | |
| QA | | | | | |
| Backend | | | | | |
| Product | | | | | |

**Overall release recommendation:** **Conditional go** — ship **Week 4 + payment methods + withdraw path** to staging/production with backend on configured host, after QA checklists pass. Hold **marketing of card deposit** until PaymentSheet is done. Require **ops-linked bank + KYC** for withdraw testers until link-bank UI exists.
