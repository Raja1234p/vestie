# Vestie API integration — production readiness review (final)

**Review date:** 2026-06-02 (final audit)  
**Scope:** Mobile app Weeks **4**, **5**, **7** vs Vestie backend API docs  
**Goal:** Ship money flows without breaking existing Vestie navigation and screens.

### Build verification (2026-05-29)

| Check | Result |
|-------|--------|
| `flutter analyze` | **0 errors** (8 info-level lints only) |
| `flutter build apk --debug` | **Success** (`app-debug.apk`) |

**How to re-verify before QA or release:**

```bash
flutter pub get
flutter analyze          # must report 0 errors
flutter build apk --debug
# Mac only:
flutter build ios --debug --no-codesign
```

---

## Executive summary

| Week | Production-ready? | Summary |
|------|-------------------|---------|
| **Week 4** | **Go** | Wallet + contribute + pot on detail + SignalR + disclaimer on Contribute + payment picker when wallet short |
| **Week 5** | **Go** | Payment methods API + Stripe PaymentSheet deposit + SetupIntent add card (release) |
| **Week 7** | **Go** | Withdraw + KYC + bank browser onboarding + announcements + notifications + FCM; wallet/notifications retry UI |

**Base URL (app):** `https://api.vestie.app/api/v1.0` (`lib/core/constants/api_constants.dart`). Confirm with backend before store release.

**QA:** Run [manual_test_runbook.md](manual_test_runbook.md) then [week_4_qa.md](week_4_qa.md) → [week_5_qa.md](week_5_qa.md) → [week_7_qa.md](week_7_qa.md).  
**Remaining tests after card/bank/deposit/withdraw:** [final_audit_remaining_tests.md](final_audit_remaining_tests.md).

---

## Cross-cutting production checklist

| Item | Status | Notes |
|------|--------|--------|
| Auth Bearer on protected routes | Ready | `BaseApiClient` |
| Risk disclaimer before wallet / Contribute / deposit / withdraw / KYC | Ready | `RiskDisclaimerGate` |
| Idempotency-Key on contribute, deposit intent, withdraw | Ready | `idempotency_key.dart` |
| Failure → user message | Ready | `FailureMapper` + `AppSnackBar` |
| Logout cache invalidation | Ready | Wallet, payments, Stripe, KYC, bank, FCM |
| Shimmer on API screens | Ready | Wallet, notifications, payment methods, bank, KYC |
| API failure UX | Ready | Wallet & notifications: **Try Again**; payment methods: error, no mock cards |
| Stripe PaymentSheet (deposit + add card release) | Ready | [stripe_test_cards.md](stripe_test_cards.md) |
| SignalR pot / contribution | Ready | `ProjectRealtimeScope` + pot refresh |
| Manual QA | Ready | [manual_test_runbook.md](manual_test_runbook.md) |

---

# Week 4 — Contributions & accounting

## API alignment

| # | Endpoint | App | Production |
|---|----------|-----|------------|
| 1 | `GET /wallet` | `WalletCubit` | **Ready** — balance, borrowed, `lockedInProjects`, `pendingWithdrawal`, `recentTransactions` |
| 2 | `POST /projects/{id}/contributions` | `ContributeBloc` | **Ready** — `{ amount }`, idempotency, 201 `projectPot` / `vffMemberUserIds` applied on return |
| 3 | `GET /projects/{id}/pot` | `GetProjectPotUseCase` + detail bloc | **Ready** — pot amount, contributor count, VFF on members |

## UI / flows

| Screen | Ready? | Notes |
|--------|--------|--------|
| Wallet tab | Yes | Shimmer; balance + borrowed; retry on load failure (locked/pending rows removed from UI) |
| Contribute | Yes | Disclaimer on entry; confirm gated on wallet total or card; dedicated payment picker |
| Project detail pot | Yes | Raised amount + contributor count from pot |
| Card-only contribute | Partial | API is wallet debit; card path prompts deposit if short |

**Verdict:** **Go** — QA [week_4_qa.md](week_4_qa.md).

---

# Week 5 — Stripe, deposits, payment methods

| Flow | Status |
|------|--------|
| Deposit intent → PaymentSheet → poll | **Ready** |
| Add card SetupIntent → PaymentSheet → attach | **Ready** |
| Payment methods list / primary / remove | **Ready** |
| Transaction history screen | **Mock** — out of W5 scope |

**Verdict:** **Go** for deposit + card management — QA [week_5_qa.md](week_5_qa.md).

---

# Week 7 — Withdrawals, KYC, banks, announcements, notifications, FCM

| Area | Status |
|------|--------|
| Withdraw preview / submit / poll | **Ready** |
| KYC browser onboarding | **Ready** |
| Bank link browser (`POST /bank-accounts`) | **Ready** |
| Bank list + empty state + add bank | **Ready** |
| Bank list / default / remove | **Ready** — Profile → **My Accounts** + withdraw picker |
| Announcements create / list / delete | **Ready** |
| Notifications + mark-read on tap | **Ready** |
| FCM register / unregister | **Ready** (device + Firebase files) |

**Verdict:** **Go** — QA [week_7_qa.md](week_7_qa.md).

---

# Production go / no-go matrix

| Capability | Go? | QA doc |
|------------|-----|--------|
| Login / dashboard / projects | **Go** | Runbook §3 |
| Risk disclaimer (wallet + Contribute) | **Go** | week_4 §3 |
| Wallet balances (+ borrowed) | **Go** | week_4 §1 |
| Contribute ($5+, 15%, payment picker) | **Go** | week_4 §2 |
| Payment methods manage | **Go** | week_5 §2 |
| Deposit (PaymentSheet) | **Go** | week_5 §3 + stripe_test_cards |
| Withdraw Standard/Instant | **Go** | week_7 §3 |
| KYC browser onboarding | **Go** | week_7 §1 |
| Link bank in app | **Go** | week_7 §2 |
| Announcements | **Go** | week_7 §5 |
| Notifications + mark-read | **Go** | week_7 §6 |
| FCM token lifecycle | **Go** | week_7 §7 (ops verify) |
| Project pot / SignalR | **Go** | week_4 §4 |

---

# Recommended pre-release actions

### P0 — must run

1. `flutter analyze` (0 errors) + `flutter build apk --debug`.  
2. Full [manual_test_runbook.md](manual_test_runbook.md) on a **physical device**.  
3. Week 4 → 5 → 7 checklists with Stripe **test** cards only on staging.

### P1 — optional polish

4. Bank remove settings UI.  
5. Transaction history from API when endpoint exists.  
6. Wallet “View all” activity from API (if separate from `GET /wallet`).

---

# Sign-off

| Role | Name | Date | Week 4 | Week 5 | Week 7 |
|------|------|------|--------|--------|--------|
| Mobile dev | | | | | |
| QA | | | | | |
| Backend | | | | | |
| Product | | | | | |

**Overall release recommendation:** **Conditional go** — ship after QA checklists pass on `api.vestie.app` (or approved production host). Use Stripe test cards on staging; real cards only on production with live keys.
