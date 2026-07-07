# Vestie API Integration Plan (Week 4 + Week 5 + Week 7)

**Manual QA:** [docs/qa/README.md](qa/README.md) → **[Runbook](qa/manual_test_runbook.md)** · [Stripe cards](qa/stripe_test_cards.md) · [Permissions](qa/permissions_and_platform_qa.md) · [API sync matrix](qa/api_screen_sync_matrix.md) · [Week 4](qa/week_4_qa.md) · [Week 5](qa/week_5_qa.md) · [Week 7](qa/week_7_qa.md) · [Production review](qa/production_readiness_review.md)

Production-ready mobile integration following **clean architecture** (`data` / `domain` / `presentation`), **`ApiConstants`**, **`ServiceLocator`**, **`FailureMapper`**, and **`.cursor/rules/pre_commit.mdc`**.

**Base URL:** `ApiConstants.baseUrl` = `https://api.vestie.app/api/v1.0` (Vestie Week 4 API doc).

**SignalR hub:** `ApiConstants.projectsHubUrl` → `https://api.vestie.app/hubs/projects` (not under `/api/v1.0`).

All REST paths are relative to `baseUrl` (e.g. `/wallet`, `/projects/{id}/contributions`). SignalR uses `projectsHubUrl` on the site root.

---

## Cross-cutting rules (all weeks)

| Topic | Implementation |
|--------|----------------|
| **Auth** | `Authorization: Bearer <accessToken>` on protected routes |
| **Risk disclaimer** | `POST /users/me/risk-disclaimer` — **required** before **wallet**, **deposit**, **KYC**, **bank accounts**, **withdrawals** (and Week 5 Stripe Connect if used). `403` → route to agreement flow. **Not** required for saved-card payment-methods routes or notifications inbox (see table below). |
| **Idempotency** | `Idempotency-Key` on `POST /wallet/deposit/intent`, `POST /projects/{id}/contributions`, `POST /wallet/withdrawals` (recommended) |
| **Errors** | Map `400` / `403` / `404` / `409` / `503` via `FailureMapper` → `AppToast` (actions) / `AppErrorView` (load) / inline field errors |
| **Sync** | Session caches + invalidate on logout, successful deposit, successful contribution |
| **No widgets → API** | Repositories + use cases only; Cubit/Bloc owns loading/submit state |
| **Strings / colors** | `AppStrings`, `AppColors` only |

### Session sync flags (extend `DashboardPrefetch`)

```dart
// lib/features/dashboard/domain/dashboard_prefetch.dart
static bool userMeLoadedOnDashboard = false;
static bool riskDisclaimerAccepted = false;   // from GET /users/me or local after POST
static bool walletLoadedOnDashboard = false;
static DateTime? walletFetchedAt;

static void invalidateWallet();  // after deposit complete, contribution, logout
static void reset();             // logout — clear all flags + caches
```

### Caches

| Cache | Key | Invalidate when |
|-------|-----|-----------------|
| `WalletBalanceCache` | user session | Deposit completed, contribution POST success, logout |
| `PaymentMethodsCache` | user session | Add/remove/set primary card |
| `StripeConfigCache` | app session | App start / env change |
| Project pot | `projectId` | Contribution success, SignalR `pot_updated` (Week 4 P5) |
| `KycStatusCache` | user session | KYC complete / `account.updated` webhook; invalidate on logout |
| `BankAccountsCache` | user session | Link/remove bank; invalidate on logout |
| Withdrawal in-flight | `withdrawalId` | Poll until terminal state; then refresh wallet |

---

## Risk disclaimer (all weeks) — `POST /users/me/risk-disclaimer`

**Endpoint:** `POST /users/me/risk-disclaimer` (full URL = `[baseUrl]/users/me/risk-disclaimer`)  
**Payload:** `{ "disclaimerVersion": "1.0", "ipAddress": "..." }`  
**Response:** `{ "message": "Risk disclaimer accepted." }`

### Required before (mobile must gate → `403` handling)

| Domain | Week | Endpoints / flows |
|--------|------|-------------------|
| Wallet balances | 4, 5, 7 | `GET /wallet` |
| Deposits | 5 | `POST /wallet/deposit/intent`, `POST /wallet/deposit` (dev) |
| Contributions | 4 | `POST /projects/{projectId}/contributions` |
| Stripe Connect (legacy path) | 5 | `POST /stripe/connect/account` |
| **KYC** | **7** | `POST /kyc/start`, `GET /kyc/status` |
| **Bank accounts** | **7** | `POST/GET/DELETE /bank-accounts` |
| **Withdrawals** | **7** | `POST /wallet/withdrawals/preview`, `POST /wallet/withdrawals` |

### Not required

| Domain | Endpoints |
|--------|-----------|
| Payment methods (saved cards) | `GET/POST/PATCH/DELETE /payment-methods*` |
| Notifications (push inbox) | `GET/POST /notifications*` (unless backend adds gate) |
| Project announcements | Leader/co-leader only — member auth via project role |

### App implementation

| Piece | Action |
|-------|--------|
| `AcceptRiskDisclaimerUseCase` | Already exists — ensure called from agreement screen |
| `RiskDisclaimerGate` | Service or cubit helper: `ensureAccepted()` before wallet/KYC/bank/withdraw navigation |
| `DashboardPrefetch.riskDisclaimerAccepted` | Set `true` after successful POST; read from `GET /users/me` if API exposes flag |
| Wallet tab / Deposit / Withdraw entry | Call gate before API; on `403` → `AppRoutes.agreement` |
| Logout | `DashboardPrefetch.reset()` clears disclaimer flag if server session ends |

---

# Week 4 — Contributions & Accounting

**Core rules:** 15% platform fee on contributions · min $5 · VFF recalc after each contribution · double-entry ledger (server-side).

## Week 4 deliverables

| Deliverable | Mobile responsibility |
|-------------|---------------------|
| Wallet balances | `GET /wallet` |
| Contribute to pot | `POST /projects/{projectId}/contributions` |
| Pot visibility | `GET /projects/{projectId}/pot` |
| Real-time | SignalR `ProjectsSignalRService` — see **§5 Real-Time** below |

## Week 4 — Endpoint → screen map

| # | Method | Endpoint | Screen / flow |
|---|--------|----------|----------------|
| 1 | GET | `/wallet` | **Wallet tab** — Available / Locked / Borrowed |
| 2 | POST | `/projects/{projectId}/contributions` | **Contribute flow** — confirm submit |
| 3 | GET | `/projects/{projectId}/pot` | **Project detail** — pot, contributor count, VFF badges |

### 2.1 Wallet tab

**Files:** `wallet_screen.dart`, `WalletCubit`, `wallet_overview_card.dart`

| UI | API field |
|----|-----------|
| Wallet Balance | `availableBalance` |
| Borrowed | `borrowedBalance` |
| Locked (if shown) | `lockedInProjects` |
| Recent Activity | *Not Week 4* — keep mock until ledger list API |

### 2.2 Contribute flow

**Files:** `contribute_flow_screen.dart`, `ContributeBloc`

| Step | API / logic |
|------|-------------|
| Init | `GET /wallet` (balance check) |
| Amount | Client: min $5, fee 15% = `ContributionFeePolicy` |
| Confirm | Display `amount`, `fee`, `totalDebited` (no legacy `/contributions/preview`) |
| Submit | `POST /projects/{projectId}/contributions` + `Idempotency-Key` |
| Success | Response: `walletAvailableBalance`, `projectPot`, `vffMemberUserIds` |
| After success | Invalidate wallet cache; refresh project pot on detail |

**Remove:** Legacy `ContributionsRemoteDataSourceImpl` paths (`/contributions/config`, `/preview`, `/confirm`, `/pot-balance`).

### 2.3 Project detail

**Files:** `ProjectDetailBloc`, member rows, VFF badges

| UI | API |
|----|-----|
| Pot / raised | `GET /pot` → `potAmount` |
| Contributors | `contributorCount` |
| VFF on members | `vffMemberUserIds` |

### Week 4 — Architecture (new / refactor)

```
wallet/                    # GET /wallet
features/project_pot/               # GET /projects/{id}/pot
user/features/contributions/        # REFACTOR → POST /projects/{id}/contributions
```

**PR order:** P0 foundation → P1 wallet GET → P2 pot GET → P3 contribution POST → P4 cross-screen sync → P5 SignalR.

### 2.4 Real-Time (SignalR) — implemented

| Item | Mobile |
|------|--------|
| Hub | `lib/core/realtime/projects_signalr_service.dart` → `GET` negotiate + WebSocket to `/hubs/projects` |
| Auth | Bearer via `accessTokenFactory` (same token as REST) |
| Connect | `DashboardScreen` after login; `disconnect` on logout |
| Join / leave | `ProjectRealtimeScope` on project detail routes → `JoinProjectChannel` / `LeaveProjectChannel` |
| Events | `contribution_made`, `pot_updated` → `RefreshProjectPotEvent` → `GET /pot` merge |
| UI merge | `project_detail_pot_extensions.dart` — `potAmount` + `vffMemberUserIds` on members |

---

# Week 5 — Stripe Connect, Deposits & Payment Methods

**Backend deliverables (not in app):** Stripe webhooks → `WebhookEvents` + Hangfire · ledger mapping · daily reconciliation · Azure Function relay.  
**Mobile:** All user-facing REST endpoints below + Stripe SDK (PaymentSheet / SetupIntent).

## Week 5 — Platform deliverables (reference)

| Deliverable | Implementation (server) | Mobile touchpoint |
|-------------|-------------------------|-------------------|
| Stripe Connect (Express, MoR) | `POST /stripe/connect/account`, onboarding link | Onboarding WebView / external browser |
| Payment intents for deposits | `POST /wallet/deposit/intent` | Deposit flow + Stripe SDK |
| Secure + idempotent webhooks | `POST /stripe/webhook` | *None* — poll status (#7) |
| Map Stripe → ledger | `payment_intent.succeeded` | Reflected in #7 + `GET /wallet` |
| Reconciliation | Hangfire jobs | User sees completed via poll |
| Azure Function webhook relay | Function → API | *None* |
| Saved payment methods | `GET/POST /payment-methods` + setup intent | Profile payment screens |

## Week 5 — Prerequisites (already partial in app)

| # | Endpoint | Screen | Status in app |
|---|----------|--------|----------------|
| 0a | `POST /auth/login` | Login | ✅ Wired |
| 0b | `POST /users/me/risk-disclaimer` | Agreement / gating | ✅ Partial — enforce **403** before wallet/deposit/Connect |

**Gating rule:** Before `GET /wallet`, `POST /wallet/deposit/intent`, or `POST /stripe/connect/account`, ensure disclaimer accepted; on `403`, route to agreement flow.

---

## Week 5 — Full endpoint → screen map

| # | Method | Endpoint | Screen / flow | Risk disclaimer? |
|---|--------|----------|---------------|-------------------|
| 1 | GET | `/stripe/config` | App init / deposit / add-card entry | No |
| 2 | POST | `/stripe/connect/account` | **Stripe Connect onboarding** (new or settings) | **Yes** |
| 3 | POST | `/stripe/connect/accounts/{accountId}/onboarding-link` | Resume expired KYC link | No |
| 4 | POST | `/stripe/webhook` | *Server only* | — |
| 5 | GET | `/wallet` | **Wallet tab**, contribute balance chip | **Yes** |
| 6 | POST | `/wallet/deposit/intent` | **Deposit amount → confirm** | **Yes** |
| 7 | GET | `/wallet/deposit/{paymentIntentId}/status` | **Deposit polling / success** | **Yes** |
| 8 | POST | `/wallet/deposit` | **Dev only** simulated deposit | **Yes** |
| 9 | GET | `/payment-methods` | **Payment Methods** list, wallet selection mode | No |
| 10 | POST | `/payment-methods/setup-intent` | **Add card** (Stripe SDK) | No |
| 11 | POST | `/payment-methods` | **Add card** save after SDK | No |
| 12 | GET | `/payment-methods/{paymentMethodId}` | **Card detail** bottom sheet | No |
| 13 | PATCH | `/payment-methods/{paymentMethodId}/primary` | Card detail — Set Primary toggle | No |
| 14 | DELETE | `/payment-methods/{paymentMethodId}` | Card detail — Remove card | No |

---

## Week 5 — Screen-by-screen detail

### Stripe Connect (#2–#3) — use KYC only (app decision)

| Step | API | UI in app |
|------|-----|-----------|
| Load SDK config | `GET /stripe/config` | Deposit + add-card (`publishableKey`) |
| Payout / identity | Week 7 `GET /kyc/status`, `POST /kyc/start` | `KycOnboardingScreen` (WebView) — **withdraw gate** |
| Connect account (#2) | `POST /stripe/connect/account` | **Not implemented** — backend may map Connect to KYC |
| Onboarding link (#3) | `POST /stripe/connect/accounts/{accountId}/onboarding-link` | **Not implemented** — use `/kyc/start` refresh instead |

**Product note:** Do not add a separate Stripe Connect screen unless product requires it alongside KYC. Withdrawals use **Profile → KYC** flow, not `stripe/connect/*` endpoints.

---

### Wallet tab + deposit flow (replace mock transaction flow)

**Current:** `transaction_amount_screen.dart` → payment method → confirmation (mock).  
**Target:**

| Step | API | Files |
|------|-----|-------|
| 1 | `GET /wallet` | `WalletCubit` — baseline balance |
| 2 | `POST /wallet/deposit/intent` `{ amount }` | `WalletDepositBloc` — returns `clientSecret`, `paymentIntentId` |
| 3 | Stripe SDK confirm | `flutter_stripe` PaymentSheet with `clientSecret` |
| 4 | Poll | `GET /wallet/deposit/{paymentIntentId}/status` until `Completed` / `Failed` / `Cancelled` |
| 5 | Refresh | `GET /wallet` — update overview card |
| 6 (dev) | `POST /wallet/deposit` | Feature flag `EnableSimulatedWalletDepositEndpoint` — skip Stripe in dev |

**Deposit status enum (map in domain):**

| API `status` | UI |
|--------------|-----|
| `Pending` | Loading / “Processing payment…” |
| `Completed` | `transaction_success_screen` |
| `Failed` | Error + retry |
| `Cancelled` | Pop with message |
| `Aborted` | Error (deposit aborted) |
| `Exhausted` | Error (retry deposit) |

**Idempotency:** `Idempotency-Key: deposit-intent-{uuid}` on step 2; reuse same key on retry.

**Withdraw flow:** Implemented in **Week 7** (see below). Remove mock-only `WalletTransactionCubit` withdraw path when W7-2 ships.

---

### Payment Methods (Profile)

**Current:** `payment_methods_screen.dart`, `add_card_screen.dart`, `card_detail_sheet.dart`, mocks in `PaymentMethodsCubit`.

| Action | API | UI |
|--------|-----|-----|
| List | `GET /payment-methods` | Replace `MockProfileData.cards` |
| Add card (production) | `POST /setup-intent` → SDK → `POST /payment-methods` `{ paymentMethodId }` | `add_card_screen.dart` |
| Add card (QA) | `POST /payment-methods` raw card fields | Dev/test builds only |
| Detail | `GET /payment-methods/{id}` | `CardDetailSheet` |
| Set primary | `PATCH /payment-methods/{id}/primary` `{ isPrimary: true }` | Custom switch (already UI) |
| Remove | `DELETE /payment-methods/{id}` | Trash action |

**Wallet selection mode** (`PaymentMethodsScreen(isSelectionMode: true)`):  
`GET /payment-methods` — same list; selection returns `paymentMethodId` to deposit flow if deposits support saved cards later.

---

### Contribute flow — payment methods (Week 4 + 5)

Week 5 **payment-methods** APIs do **not** require risk disclaimer; Week 4 **contribution** debits **wallet** only.

| Flow | Payment UI |
|------|------------|
| Contribute | Wallet balance from `GET /wallet`; hide card picker until API supports card-funded contributions |
| Deposit | Stripe PaymentIntent (#6–#7) |

---

## Week 5 — Architecture (new modules)

```
lib/
├── core/
│   ├── constants/api_constants.dart     # + stripe/*, wallet/deposit/*, payment-methods/*
│   └── stripe/
│       └── stripe_sdk_initializer.dart  # publishableKey from GET /stripe/config
│
├── features/stripe_connect/             # optional product slice
│   └── data/ ... connect account + onboarding link
│
├── wallet/                       # Week 4 + Week 5 deposit
│   ├── data/
│   │   ├── wallet_remote_data_source.dart
│   │   ├── wallet_deposit_remote_data_source.dart
│   │   └── models/ ...
│   └── presentation/
│       ├── cubit/wallet_cubit.dart
│       └── cubit/wallet_deposit_cubit.dart
│
└── features/payment_methods/              # refactor profile/payment into feature
    ├── data/
    │   └── payment_methods_remote_data_source.dart
    └── presentation/                      # wire existing screens
```

**Consolidate:** Move `PaymentMethodsCubit` off mocks → `PaymentMethodsRepository`.

**Stripe SDK:** Add `flutter_stripe` (or existing package); initialize with `publishableKey` from #1.

---

## Week 5 — Sync & production checklist

| Event | Actions |
|-------|---------|
| Deposit `Completed` | `WalletBalanceCache.update`; `DashboardPrefetch.invalidateWallet`; refresh wallet tab if visible |
| Deposit `Failed` | Show `failureReason`; allow retry with **new** idempotency key |
| Card added | Refresh `GET /payment-methods`; invalidate selection caches |
| Logout | `DashboardPrefetch.reset()`; clear Stripe customer cache |
| App resume during deposit poll | Resume polling `GET .../status` with backoff (max 30–60s) |

### Polling strategy (#7)

```
after SDK payment success:
  loop every 2s:
    GET /wallet/deposit/{pi}/status
    if Completed → success screen + refresh wallet
    if Failed/Cancelled → error
    timeout 90s → "Still processing" + manual refresh wallet
```

Webhook latency is server-side; mobile must not assume instant completion.

---

## Combined PR roadmap (Week 4 → Week 5)

| Phase | Scope | Depends on |
|-------|--------|------------|
| **W4-0** | ApiConstants **paths only** (no `baseUrl` change), entities, fee policy, disclaimer gating | — |
| **W4-1** | `GET /wallet` — wallet tab | W4-0 |
| **W4-2** | `GET /pot` — project detail | W4-0 |
| **W4-3** | `POST /contributions` — contribute flow | W4-1 |
| **W4-4** | Cross-screen sync | W4-1–3 |
| **W5-0** | `GET /stripe/config`, Stripe SDK init | W4-0 |
| **W5-1** | Payment methods CRUD (#9–#14) | W5-0 |
| **W5-2** | Deposit intent + poll (#6–#7) | W4-1, W5-0, disclaimer |
| **W5-3** | Simulated deposit (#8) dev flag | W5-2 |
| **W5-4** | Stripe Connect (#2–#3) if required | W5-0, disclaimer |
| **W5-5** | E2E QA script + remove mocks | W5-1–4 |
| **W7-0** | ApiConstants, KYC/bank/withdraw models, disclaimer gate hardening | W4-0 |
| **W7-1** | `GET /kyc/status`, `POST /kyc/start` (WebView) | W7-0, disclaimer |
| **W7-2** | Bank accounts CRUD + withdraw method picker | W7-1 |
| **W7-3** | Withdraw preview + initiate + poll | W7-2, W4-1 |
| **W7-4** | `GET /wallet` v2 — `pendingWithdrawal`, `recentTransactions` | W7-3 |
| **W7-5** | Project announcements + notifications | W4-2, auth |
| **W7-6** | FCM device token register/unregister | W7-5 |

---

# Week 7 — Withdrawals, KYC, Bank Accounts, Announcements & Notifications

**Backend (not in app):** Extended `POST /stripe/webhook` (`payout.paid`, `payout.failed`, `account.updated`) · Hangfire `wallet:withdrawal-monitor`, `kyc:pending-reminders`.

## Week 7 deliverables

| Deliverable | Implementation |
|-------------|----------------|
| Withdrawal preview (Standard / Instant) | `POST /wallet/withdrawals/preview` |
| Initiate withdrawal to bank | `POST /wallet/withdrawals` |
| Poll withdrawal status | `GET /wallet/withdrawals/{withdrawalId}` |
| KYC onboarding (Stripe Connect Express) | `POST /kyc/start`, `GET /kyc/status` |
| Link / list / remove bank accounts | `POST` / `GET` / `DELETE /bank-accounts` |
| Wallet pending withdrawal + history | `GET /wallet` (updated response) |
| Payout + KYC webhooks | Server — mobile polls withdrawal + refreshes KYC/wallet |
| Project announcements | `GET /projects/{id}` + `POST`/`DELETE` announcements |
| Push notifications | FCM token + inbox APIs |

## Week 7 — Endpoint → screen map

| # | Method | Endpoint | Screen / flow | Risk disclaimer? |
|---|--------|----------|---------------|-------------------|
| 0b | POST | `/users/me/risk-disclaimer` | Agreement (prerequisite) | — |
| 1 | POST | `/wallet/withdrawals/preview` | **Withdraw confirm** — fee, `youWillReceive`, `processingTime`, `destinationDisplay` | **Yes** |
| 2 | POST | `/wallet/withdrawals` | **Withdraw submit** — debit wallet, start payout | **Yes** |
| 3 | GET | `/wallet/withdrawals/{withdrawalId}` | **Withdraw success** — poll Processing → Completed/Failed | **Yes** |
| 4 | POST | `/kyc/start` | **KYC onboarding** — open `onboardingUrl` | **Yes** |
| 5 | GET | `/kyc/status` | **Withdraw gate**, settings, return from KYC WebView | **Yes** |
| 6 | POST | `/bank-accounts` | **Link bank** — token or onboarding URL | **Yes** |
| 7 | GET | `/bank-accounts` | **Withdraw method** — pick `bankAccountId` | **Yes** |
| 8 | DELETE | `/bank-accounts/{bankAccountId}` | Bank management (settings) | **Yes** |
| * | GET | `/wallet` | **Wallet tab** — `pendingWithdrawal`, `recentTransactions[]` | **Yes** |
| 9 | GET | `/projects/{id}` | **Project detail** — includes `announcements[]` | Member auth |
| 10 | POST | `/projects/{projectId}/announcements` | **Create announcement** (leader/co-leader) | Role-based |
| 11 | DELETE | `/projects/{projectId}/announcements/{announcementId}` | Delete announcement | Role-based |
| 12 | POST | `/notifications/device-token` | App launch / login — register FCM | No |
| 13 | DELETE | `/notifications/device-token` | Logout — unregister FCM | No |
| 14 | GET | `/notifications` | **Notifications** screen (`?page`, `pageSize`) | No |
| 15 | POST | `/notifications/mark-read` | Mark read on tap / bulk | No |

### Withdrawal business rules (domain layer)

| Rule | Value | Where |
|------|-------|--------|
| Min withdrawal | **$10** | `ValidationUtils` + API `400` |
| Standard fee | **0%** | Preview response |
| Instant fee | **1.5%** | `feePercent` / `feeAmount` from preview |
| Processing copy | Standard: `1-3 business days` · Instant: `~30 mins` | Map from preview `processingTime` |
| Prerequisites | KYC **Verified** + `payoutsEnabled` + linked bank + sufficient balance | Gate before withdraw flow |

### 7.1 Withdraw flow (replace mock UI)

**Current app screens:** `transaction_amount_screen` (withdraw) → `withdraw_method_screen` → `select_payment_method` → `transaction_confirmation_screen`.

**Target flow:**

```
Wallet tab → Withdraw
  → [gate] risk disclaimer + GET /kyc/status (Verified?)
  → [gate] GET /bank-accounts (non-empty?)
  → Amount + type (Standard | Instant)     // withdraw_method_screen
  → POST /wallet/withdrawals/preview       // confirmation UI: fee, youWillReceive
  → POST /wallet/withdrawals { amount, type, bankAccountId }
  → Poll GET /wallet/withdrawals/{withdrawalId}
  → Success / failure
  → GET /wallet (refresh balances + recentTransactions)
```

| Step | API | Files to wire |
|------|-----|----------------|
| Enter amount + type | Client validation min $10 | `withdraw_method_screen`, `WalletWithdrawCubit` |
| Confirm breakdown | `POST /wallet/withdrawals/preview` | `transaction_confirmation_screen`, `wallet_withdraw_confirm_section` |
| Submit | `POST /wallet/withdrawals` | Same + `Idempotency-Key` |
| Poll | `GET /wallet/withdrawals/{withdrawalId}` every 2–5s | `transaction_success_screen` or dedicated processing view |
| Wallet home | `GET /wallet` | `WalletCubit` — show `pendingWithdrawal` |

**WithdrawalType enum:** `Standard` | `Instant` (match API strings exactly).

**WithdrawalStatus enum:** `Processing` | `Completed` | `Failed`.

**Back navigation:** Same stack rules as deposit (pop to payment method / amount, not loop confirm).

### 7.2 KYC flow

| Step | API | UI |
|------|-----|-----|
| Check | `GET /kyc/status` | Before withdraw: if not `Verified` → block with CTA “Complete verification” |
| Start | `POST /kyc/start` `{ country?, refreshUrl, returnUrl }` | Open `onboardingUrl` in `url_launcher` / in-app WebView |
| Return | Deep link / app resume | Re-fetch `GET /kyc/status` |
| Status values | `NotStarted`, `Pending`, `Verified`, `Rejected` | Badges + disable withdraw when not Verified |

**Note:** Week 5 `POST /stripe/connect/account` may overlap with Week 7 `POST /kyc/start` — **consolidate on `/kyc/*`** for withdraw-specific UX; keep `/stripe/connect/*` only if product needs separate Connect settings screen.

### 7.3 Bank accounts

| Action | API | UI |
|--------|-----|-----|
| List | `GET /bank-accounts` | Withdraw method screen — show `displayName`, default flag |
| Link (SDK) | `POST /bank-accounts` `{ bankAccountToken }` | Stripe bank token collection |
| Link (browser) | `POST /bank-accounts` `{ refreshUrl, returnUrl }` | Open `onboardingUrl` from response |
| Remove | `DELETE /bank-accounts/{bankAccountId}` | Settings / bank management |
| Withdraw | Use `bankAccount.id` (`ba_...`) in `POST /wallet/withdrawals` | Selected row on confirm |

### 7.4 Wallet tab (Week 7 enhancement)

Extend Week 4/5 `GET /wallet` model:

| Field | UI |
|-------|-----|
| `walletBalance` / `availableBalance` | Wallet Balance row |
| `borrowedBalance` | Borrowed pill |
| `lockedInProjects` | Optional locked row |
| `pendingWithdrawal` | Banner or subtitle when &gt; 0 |
| `recentTransactions[]` | **Replace** `MockProfileData.transactions` on wallet tab |

Map `recentTransactions` → `AppTransactionItem` (`type`, `title`, `amount`, `direction` Debit/Credit, `date`).

### 7.5 Project detail — announcements

| Action | API | UI |
|--------|-----|-----|
| Load | `GET /projects/{id}` → `announcements[]` | Announcements panel on detail (leader + member views) |
| Create | `POST /projects/{projectId}/announcements` multipart (`heading`, `content`, optional repeatable `attachments`) | `create_announcement_screen.dart` |
| Delete | `DELETE .../announcements/{announcementId}` | Leader moderation UI |

Merge into existing `ProjectDetailBloc` refresh after create/delete.

### 7.6 Notifications & FCM

| Action | API | When |
|--------|-----|------|
| Register token | `POST /notifications/device-token` `{ token, platform: "iOS"\|"Android" }` | After login / on dashboard activate |
| Unregister | `DELETE /notifications/device-token` `{ token }` | Logout |
| List inbox | `GET /notifications?page=&pageSize=` | `notifications_screen.dart` — replace mock |
| Mark read | `POST /notifications/mark-read` `{ notificationIds: [] }` | On tap / “mark all” |

**FCM:** Wire `firebase_messaging` (if not already) to pass token to register endpoint; handle foreground → refresh unread count on `GET /notifications` or local badge.

#### Firebase config files (W7-6 prerequisite)

Copy from Downloads into the repo before enabling push (files are **not** in the repo yet):

| Platform | Source path (local) | Target path in Vestie |
|----------|---------------------|------------------------|
| **iOS** | `C:\Users\hp\Downloads\GoogleService-Info.plist` | `ios/Runner/GoogleService-Info.plist` |
| **Android** | `C:\Users\hp\Downloads\google-services.json` | `android/app/google-services.json` |

**Setup checklist (W7-6):**

1. Copy both files to the target paths above (same Firebase project as backend FCM).
2. iOS: add `GoogleService-Info.plist` to the **Runner** target in Xcode if not picked up automatically.
3. Android: ensure root `android/build.gradle` applies `com.google.gms.google-services` and `android/app/build.gradle` applies the plugin (FlutterFire default).
4. Add `firebase_core` + `firebase_messaging` to `pubspec.yaml` if missing; run `flutterfire configure` only if you regenerate configs — otherwise manual copy is enough.
5. Do **not** commit secrets to a public repo without team policy; treat these like env-specific assets (many teams gitignore them or use CI-injected copies).

---

## Week 7 — Architecture (new modules)

```
lib/
├── features/kyc/
│   ├── data/ ... kyc_remote_data_source.dart
│   └── domain/ ... GetKycStatusUseCase, StartKycUseCase
│
├── features/bank_accounts/
│   ├── data/ ... bank_accounts_remote_data_source.dart
│   └── domain/ ... ListBankAccountsUseCase, LinkBankAccountUseCase, RemoveBankAccountUseCase
│
├── features/wallet_withdrawal/          # or extend wallet/
│   ├── data/ ... withdrawal preview, initiate, status models
│   └── domain/ ... PreviewWithdrawalUseCase, InitiateWithdrawalUseCase, GetWithdrawalStatusUseCase
│
├── features/notifications/
│   ├── data/ ... notifications + device_token
│   └── presentation/ ... NotificationsCubit, inbox UI
│
└── features/project_detail/           # extend existing
    └── announcements/ ... create/delete use cases
```

**Refactor:** `WalletTransactionCubit` withdraw/deposit paths → `WalletDepositCubit` (W5) + `WalletWithdrawCubit` (W7).

---

## Week 7 — Sync & production checklist

| Event | Actions |
|-------|---------|
| Withdrawal `Completed` | Stop poll; refresh `GET /wallet`; clear in-flight withdrawal id |
| Withdrawal `Failed` | Show `failureReason`; wallet balance restored server-side — refresh wallet |
| KYC `Verified` | Update `KycStatusCache`; enable withdraw CTA |
| Bank linked | Refresh `GET /bank-accounts` |
| Announcement created/deleted | `ProjectDetailBloc.reload()` |
| Notification opened | `POST /notifications/mark-read`; decrement unread |
| Logout | Unregister FCM token; clear KYC/bank caches |

### Withdrawal polling (#3)

```
after POST /wallet/withdrawals:
  loop every 3s (max 5 min):
    GET /wallet/withdrawals/{withdrawalId}
    if Completed → success + GET /wallet
    if Failed → error with failureReason
  on timeout → "Still processing" + manual refresh wallet
```

Server also runs `wallet:withdrawal-monitor` if webhooks lag — mobile polling remains required for UX.

---

## Screen → API cheat sheet (Week 4 + 5 + 7)

| Screen / flow | APIs |
|---------------|------|
| Login | `POST /auth/login` |
| Agreement / risk | `POST /users/me/risk-disclaimer` |
| Home / Discover | `GET /projects` (existing) + refresh after contribute |
| Wallet tab | `GET /wallet` |
| Deposit | `POST /wallet/deposit/intent` → SDK → `GET .../status` → `GET /wallet` |
| Deposit (dev) | `POST /wallet/deposit` |
| Contribute | `GET /wallet` + `POST /projects/{id}/contributions` |
| Project detail | `GET /projects/{id}` + `GET /projects/{id}/pot` |
| Payment Methods list | `GET /payment-methods` |
| Add card | `POST /payment-methods/setup-intent` → SDK → `POST /payment-methods` |
| Card detail sheet | `GET`, `PATCH .../primary`, `DELETE` |
| Stripe Connect (W5) / KYC (W7) | `GET /stripe/config`, `POST /kyc/start`, `GET /kyc/status` |
| Profile / Wallet selection | `GET /payment-methods` |
| Withdraw — preview | `POST /wallet/withdrawals/preview` |
| Withdraw — submit + poll | `POST /wallet/withdrawals`, `GET /wallet/withdrawals/{id}` |
| Bank accounts | `GET/POST/DELETE /bank-accounts` |
| Notifications inbox | `GET /notifications`, `POST /notifications/mark-read` |
| Push token | `POST/DELETE /notifications/device-token` |
| Announcements | `GET /projects/{id}`, `POST/DELETE .../announcements` |

---

## Testing matrix

### Week 4
- [ ] Contribute &lt; $5 blocked client-side  
- [ ] Fee 15% matches API response  
- [ ] Insufficient balance → 400  
- [ ] Idempotent double-submit on contribute  

### Week 5
- [ ] Disclaimer not accepted → 403 on wallet/deposit  
- [ ] Deposit $50 → poll Completed → balance updated  
- [ ] Pending deposit → poll until webhook processed  
- [ ] Add card via SetupIntent → appears in list  
- [ ] Set primary / remove card  
- [ ] Simulated deposit (#8) only in dev builds  

### Week 7
- [ ] Disclaimer not accepted → 403 on KYC, bank, withdraw preview  
- [ ] KYC NotStarted → start onboarding → Verified  
- [ ] Withdraw &lt; $10 blocked  
- [ ] Instant preview: fee 1.5%, Standard fee 0  
- [ ] Insufficient balance / no bank / KYC not verified → 400 messages  
- [ ] Withdraw poll Processing → Completed  
- [ ] Wallet shows `pendingWithdrawal` + withdrawal in `recentTransactions`  
- [ ] Leader creates/deletes announcement on project detail  
- [ ] Notifications list paginated; mark-read works  
- [ ] `GoogleService-Info.plist` + `google-services.json` copied from Downloads into `ios/Runner/` and `android/app/`  
- [ ] FCM token registered on login, removed on logout  

### End-to-end deposit (QA)

1. `POST /auth/login`  
2. `POST /users/me/risk-disclaimer`  
3. `GET /wallet` — baseline  
4. `POST /wallet/deposit/intent` `{ amount: 50 }`  
5. Confirm with test card `4242…`  
6. Poll `GET /wallet/deposit/{pi}/status` → `Completed`  
7. `GET /wallet` — balance increased  

### End-to-end withdrawal (QA)

1. `POST /auth/login`  
2. `POST /users/me/risk-disclaimer`  
3. `GET /kyc/status` → complete `POST /kyc/start` if needed  
4. `GET /bank-accounts` (or `POST /bank-accounts` to link)  
5. Fund wallet (deposit dev or intent)  
6. `GET /wallet` — balance ≥ withdrawal amount  
7. `POST /wallet/withdrawals/preview` `{ amount, type }`  
8. `POST /wallet/withdrawals` with `bankAccountId`  
9. Poll `GET /wallet/withdrawals/{id}` → `Completed`  
10. `GET /wallet` — balance reduced, `pendingWithdrawal` updated  

---

## Legacy code to remove or gate

| Area | Action |
|------|--------|
| `ContributionsRemoteDataSourceImpl` old paths | Replace with Week 4 endpoints |
| `MockProfileData.cards` / transactions | Replace when #9 and ledger exist |
| `WalletOverviewCard` hardcoded amounts | Week 4/7 `GET /wallet` |
| `ContributeBloc` mock delays | Week 4 #3 |
| `WalletTransactionCubit` mock withdraw | Week 7 withdraw cubit + APIs |
| `MockProfileData.transactions` on wallet | Week 7 `recentTransactions` |
| `notifications_screen` mock data | Week 7 #14–#15 |
| Raw card POST in production | Gate behind `kDebugMode` / flavor |

---

## Open questions for backend / product

1. Use **`/kyc/*`** vs **`/stripe/connect/*`** as single Connect entry point for mobile?  
2. Can contributions use saved cards, or wallet-only for Week 4?  
3. Deep link URLs for KYC/bank `returnUrl` / `refreshUrl` on mobile (custom scheme vs https)?  
4. Does `GET /users/me` expose `riskDisclaimerAccepted` to skip redundant POST?  
5. Profile **Transaction History** — separate ledger API or subset of `recentTransactions`?  
6. Announcement `autoRemoveAtUtc` — show countdown on detail UI?

*(Deferred, out of scope for this plan: migrating `baseUrl` to `api.vestie.app` or `/api/v1.0`.)*

---

## ApiConstants additions (Week 7)

```dart
static const String riskDisclaimer = '/users/me/risk-disclaimer'; // existing

static const String walletWithdrawalsPreview = '/wallet/withdrawals/preview';
static const String walletWithdrawals = '/wallet/withdrawals';
static String walletWithdrawalStatus(String id) => '/wallet/withdrawals/$id';

static const String kycStart = '/kyc/start';
static const String kycStatus = '/kyc/status';

static const String bankAccounts = '/bank-accounts';
static String bankAccount(String id) => '/bank-accounts/$id';

static String projectAnnouncements(String projectId) =>
    '$projects/$projectId/announcements';
static String projectAnnouncement(String projectId, String announcementId) =>
    '$projects/$projectId/announcements/$announcementId';

static const String notificationsDeviceToken = '/notifications/device-token';
static const String notifications = '/notifications';
static const String notificationsMarkRead = '/notifications/mark-read';
```

---

*Last updated: Week 4 + Week 5 + Week 7 scope consolidated for Vestie Flutter app.*
