# Vestie — Manual test runbook (run the app)

Use this document when you **`flutter run`** or install a **release/profile** build on a **physical device**. Complete checklists in order; record **PASS / FAIL / SKIP** in each week file.

**Tester:** _______________ **Date:** _______________ **Build:** `1.0.0+___` **Device:** _______________ **OS:** _______________

---

## 1. Before you run

| Step | Action |
|------|--------|
| 1 | `flutter pub get` |
| 2 | `flutter analyze` → **0 errors** (infos OK) |
| 3 | Firebase files present: `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist` |
| 4 | Test accounts: **member** + **leader/co-leader** on at least one **active** project |
| 5 | Backend reachable: app uses `ApiConstants.baseUrl` (see [README](README.md)) |
| 6 | For **staging/production QA**: backend must return real Stripe **`publishableKey`** + deposit **`clientSecret`** (not simulated deposit) |

### Build commands

| Platform | Command | Notes |
|----------|---------|--------|
| Android debug | `flutter run` or `flutter build apk --debug` | Stripe + FCM on real device |
| Android release | `flutter build apk --release` | Signing config required for store |
| iOS debug | `flutter run` (Mac + Xcode) | Open `ios/Runner.xcworkspace` if pods fail |
| iOS release | `flutter build ipa` | Apple certs + provisioning |

---

## 2. Test order (required)

| Order | Document | Time (approx.) |
|-------|----------|----------------|
| A | [permissions_and_platform_qa.md](permissions_and_platform_qa.md) | 20 min |
| B | [week_4_qa.md](week_4_qa.md) | 30 min |
| C | [week_5_qa.md](week_5_qa.md) + [stripe_test_cards.md](stripe_test_cards.md) | 40 min |
| D | [week_7_qa.md](week_7_qa.md) | 45 min |
| E | [api_screen_sync_matrix.md](api_screen_sync_matrix.md) — verify each screen | 20 min |
| F | [production_readiness_review.md](production_readiness_review.md) — sign-off | 10 min |

---

## 3. First launch smoke (5 min)

Run once on a **fresh install** (or after clearing app data).

| # | Step | Expected | Result |
|---|------|----------|--------|
| S1 | Launch app | Splash → login or dashboard | |
| S2 | Login | Dashboard Home tab loads (shimmer → content) | |
| S3 | Notification prompt | iOS system prompt and/or in-app “Enable notifications” on dashboard | |
| S4 | Deny notifications → dashboard | App does not crash; can use app | |
| S5 | Profile → avatar → **Take Photo** | Camera permission prompt → deny → **Open Settings** dialog | |
| S6 | Profile → avatar → **Gallery** | Photos permission → deny → settings guidance | |
| S7 | Grant permissions → pick photo | Upload succeeds or clear error | |
| S8 | Wallet tab | Shimmer → balances from API | |
| S9 | Logout → login | No crash; wallet not showing previous user balance | |

---

## 4. Money flow smoke (15 min)

Prerequisites: risk disclaimer accepted.

| # | Step | Expected | Result |
|---|------|----------|--------|
| M1 | Deposit $25 | Stripe PaymentSheet → success → wallet ↑ | |
| M2 | Contribute $5+ on project | Fee 15%; wallet ↓ | |
| M3 | Withdraw $10+ (if KYC + bank) | Preview fees → success/processing | |
| M4 | Notifications | List loads; tap marks read (API mode) | |

Use [stripe_test_cards.md](stripe_test_cards.md) for card numbers.

---

## 5. Negative / edge cases (10 min)

| # | Scenario | Expected | Result |
|---|----------|----------|--------|
| N1 | Airplane mode → Wallet | Error snackbar; shimmer ends; no infinite spinner | |
| N2 | Deposit → cancel PaymentSheet | Returns to confirm; no success screen | |
| N3 | Declined card `4000…0002` | Failure message; balance unchanged | |
| N4 | Contribute below $5 | Validation blocks submit | |
| N5 | Withdraw below $10 | Validation blocks submit | |
| N6 | No disclaimer → Deposit | Agreement / gate | |
| N7 | Logout mid-flow | Next login clean state | |

---

## 6. Production vs staging

| Environment | Stripe keys | Cards to use |
|-------------|-------------|--------------|
| **Staging / QA** | Backend `pk_test_…` | [stripe_test_cards.md](stripe_test_cards.md) test cards only |
| **Production** | Backend `pk_live_…` | **Real cards only** — do not use 4242… in production |

The app **never** calls simulated `POST /wallet/deposit`. Production deposits always go through **PaymentSheet + poll**.

---

## 7. Compile & platform sign-off

| Check | Android | iOS |
|-------|---------|-----|
| `flutter analyze` 0 errors | ☐ | ☐ |
| `flutter build apk --debug` | ☐ | N/A on Windows |
| `flutter build ios --debug` (Mac) | N/A | ☐ |
| Camera / gallery / notifications QA | ☐ | ☐ |
| Week 4 / 5 / 7 checklists complete | ☐ | ☐ |
| Production readiness doc reviewed | ☐ | ☐ |

**Final sign-off:** _______________ **Date:** _______________
