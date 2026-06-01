# Vestie API integration — QA pass guide

Manual QA for **Week 4**, **Week 5**, and **Week 7**. Use with [`api_integration_plan.md`](../api_integration_plan.md).

## Start here

| Document | When to use |
|----------|-------------|
| **[manual_test_runbook.md](manual_test_runbook.md)** | **First** — order of tests, smoke scripts, build commands, sign-off |
| [permissions_and_platform_qa.md](permissions_and_platform_qa.md) | Camera, gallery, notifications, Android/iOS builds |
| [stripe_test_cards.md](stripe_test_cards.md) | Card numbers, expiry, CVC for deposit QA |
| [api_screen_sync_matrix.md](api_screen_sync_matrix.md) | Which API each screen uses + refresh rules |

## Week checklists

| File | Scope |
|------|--------|
| [week_4_qa.md](week_4_qa.md) | Wallet, contributions, pot, payment picker, disclaimer |
| [week_5_qa.md](week_5_qa.md) | Stripe config, PaymentSheet deposit, payment methods |
| [week_7_qa.md](week_7_qa.md) | Withdraw, KYC, banks, announcements, notifications, FCM |
| [production_readiness_review.md](production_readiness_review.md) | Production go/no-go vs backend |

## Environment

| Item | Value |
|------|--------|
| API base (app) | `https://api.vestie.app/api/v1.0` |
| SignalR hub | `https://api.vestie.app/hubs/projects` |
| Build | **Physical device** recommended (Stripe PaymentSheet, FCM, camera) |
| Stripe (staging) | See [stripe_test_cards.md](stripe_test_cards.md) — `4242 4242 4242 4242`, exp `12/34`, CVC `123` |
| Stripe (production) | **Real cards only** — backend must use `pk_live_…` |
| Firebase | `android/app/google-services.json` + `ios/Runner/GoogleService-Info.plist` |

## Compile gate (before every QA run)

```bash
flutter pub get
flutter analyze    # must be 0 errors
flutter build apk --debug
```

On Mac: `flutter build ios --debug --no-codesign`

## Before you start

1. Install build (`flutter run` or CI artifact).  
2. Test accounts: **member** + **leader** on an **active** project.  
3. Accept **risk disclaimer** before wallet/deposit/withdraw/KYC.  
4. For Week 7 withdraw: **KYC verified** + **bank linked** (backend/admin if no in-app link UI).

## How to record results

Mark each row: **PASS** | **FAIL** | **SKIP** | **N/A**

For **FAIL**: steps, screen, snackbar/error text, screenshot if possible.

## Suggested test order

1. [manual_test_runbook.md](manual_test_runbook.md) — first launch smoke  
2. [permissions_and_platform_qa.md](permissions_and_platform_qa.md)  
3. [week_4_qa.md](week_4_qa.md) → [week_5_qa.md](week_5_qa.md) → [week_7_qa.md](week_7_qa.md)  
4. [api_screen_sync_matrix.md](api_screen_sync_matrix.md)  
5. [production_readiness_review.md](production_readiness_review.md)

## Shimmer screens (regression)

Must show **shimmer**, not centered spinner, on first load:

- Wallet, Notifications, Payment methods, Select bank, KYC WebView start  
- Home, Discover, Project detail, Join requests, Profile header (existing)
