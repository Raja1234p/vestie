# Phase 1 — Project Analysis & Baseline Report

**Branch:** `production-optimization`  
**Date:** 2026-06-05  
**Scope:** Full Vestie Flutter app (`lib/`, `test/`, `android/`, `pubspec.yaml`)

---

## Executive summary

| Metric | Baseline |
|--------|----------|
| Dart files (`lib/`) | ~792 |
| Test files | 30 |
| `flutter test` | **107 passed** |
| `dart analyze` | **0 errors**, 6 warnings, 14 info |
| `buildWhen` usage | 3 files |
| `BlocSelector` usage | 2 files |
| `RepaintBoundary` | 0 |
| `cacheWidth`/`cacheHeight` on images | 4 files (auth icons only) |
| `GoogleFonts.lato` in `build()` | ~130+ files |

The app is **functionally production-ready** (see `DOCS/qa/production_readiness_review.md`). Optimization focus: **widget rebuild scope**, **lazy list building**, **image decode memory**, **release binary size**, and **static hygiene** — without changing UI, flows, or APIs.

---

## Architecture consistency

| Area | Status | Notes |
|------|--------|-------|
| Clean feature layout | ✅ | `data` / `domain` / `presentation` per feature |
| State management | ✅ | Cubit/Bloc; minimal `setState` for lifecycle |
| Navigation | ✅ | `go_router` + `AppRoutes` |
| DI | ✅ | `ServiceLocator` singleton, eager `init()` at startup |
| Constants | ✅ | `AppStrings`, `AppColors`, `AppAssets`, `ApiConstants` |
| Networking | ✅ | Dio + interceptors; idempotency keys on money flows |

**Deviation:** `device_preview` is a **production dependency** but only used when `!kReleaseMode` in `main.dart` — should be `dev_dependencies`.

---

## Performance bottlenecks (P0 → P2)

### P0 — Critical

| Screen / widget | Issue | Official Flutter guidance |
|-----------------|-------|---------------------------|
| `projects_section.dart` | Eager `.map()` → all `ProjectCard`s built at once inside `Column` | [Long lists](https://docs.flutter.dev/cookbook/lists/long-lists) — use builder |
| `project_card.dart` | `DottedBorder`, shadows, `GoogleFonts` per build; `Image.asset` without cache dims | [Perf best practices](https://docs.flutter.dev/perf/best-practices) |
| `home_screen.dart` | `BlocBuilder` without `buildWhen` on `HomeBloc` | Minimize rebuilds |
| `project_detail_screen.dart` | Large `BlocConsumer` tree | Split + `BlocSelector` |

### P1 — High

| Screen | Issue |
|--------|-------|
| `discover_screen.dart` | Outer `BlocBuilder` rebuilds header + filters + list on any cubit change |
| `member_detail_screen.dart` | Wide `BlocBuilder`; eager transaction rows |
| `notifications_screen.dart` | Per-row `GoogleFonts`; uncached row images |
| `user_project_detail_screen.dart` | `SliverChildListDelegate` (eager members) |

### P2 — Medium

| Screen | Issue |
|--------|-------|
| `profile_screen.dart`, `wallet_screen.dart` | Broad bloc rebuilds |
| `borrow_flow_screen.dart`, `contribute_flow_screen.dart` | Nested blocs + inline `GoogleFonts` |
| VFF hub tabs | `ListView(children: [...map])` — low impact (`previewCap = 2`) |

### Already good

- `discover_screen.dart` project list — `SliverChildBuilderDelegate`
- `transaction_history_screen.dart`, `completed_projects_screen.dart` — `ListView.builder`
- `user_vff_vff_requests_scaffold.dart` — `ListView.builder`
- `user_vff_hub_shell.dart` — `BlocSelector`
- Prefetch services — deduplicate in-flight requests (`WalletPrefetch`, etc.)

---

## Unnecessary rebuilds

| Pattern | Count | Fix |
|---------|-------|-----|
| `BlocBuilder` without `buildWhen` | Widespread | Add `buildWhen` / `BlocSelector` |
| `GoogleFonts.lato()` in `build()` | ~130+ files | Hoist to `AppTextStyles` / theme |
| `HomeSectionsCubit` toggle | Rebuilds full `_HomeContent` scaffold | `buildWhen` on section cubit (Equatable already) |
| Silent home refresh | New `HomeLoaded` lists → full card rebuild | Lazy builders + `RepaintBoundary` |

---

## Code smells & static issues (`dart analyze`)

| Severity | Count | Examples |
|----------|-------|----------|
| warning | 6 | Unused imports (`project_detail_flow_args.dart`, VFF cards, investment settings) |
| info | 14 | Unnecessary imports, `use_build_context_synchronously`, test lint style |

**Dead code:** `lib/test_auth_flow.dart` — fully commented-out integration script, not referenced.

---

## Assets

Prior session removed **28 unused** image/icon files. Current:

- `assets/icons/` — ~102 SVGs
- `assets/images/` — success/invite/header PNGs
- `assets/fonts/` — present but Lato loaded via `google_fonts` at runtime

**Opportunity:** Bundle Lato in `pubspec` fonts to remove runtime font fetch (Phase 4/7).

---

## Dependencies review

| Package | Role | Optimization note |
|---------|------|-------------------|
| `firebase_core`, `firebase_messaging` | Push | Required; init at startup |
| `flutter_stripe` | Payments | Required before `runApp` |
| `google_sign_in` | Auth | Init at startup |
| `signalr_netcore` | Realtime | Connection per scope |
| `device_preview` | Dev only | Move to `dev_dependencies` |
| `cached_network_image` | Avatars | Good; underused on some PNG rows |

Run `flutter pub outdated` periodically; SDK `^3.11.4` is current.

---

## Startup sequence (`main.dart`)

Sequential awaits before `runApp`:

1. `StripeSdkInitializer.initialize()`
2. `GoogleSignIn.instance.initialize()`
3. `SystemChrome.setPreferredOrientations`
4. `ServiceLocator.instance.init()` — heavy (all repos/use cases)
5. `FcmPushService.initialize()`
6. `ProjectInviteDeepLinkService.captureInitialInviteIfAny()`
7. `AppAuthSession.syncFromStorage()`

**Opportunity:** Keep critical path (Stripe, DI, auth session); defer orientation lock overlap is minor. FCM/deep link must stay before first route for invite flows — **do not defer** without careful testing.

---

## Network layer

| Pattern | Status |
|---------|--------|
| Bearer auth interceptor | ✅ |
| Idempotency keys (contribute, deposit, withdraw) | ✅ |
| Prefetch dedup (`_inFlight` guards) | ✅ Wallet, payment methods, bank |
| Retry UI (wallet, notifications) | ✅ |
| Response caching | Partial — `WalletBalanceCache` only |

---

## Security baseline

| Item | Status |
|------|--------|
| Tokens in `flutter_secure_storage` | ✅ |
| `debugPrint` in FCM / SignalR | ⚠️ Wrap with `kDebugMode` |
| API base URL in source | ✅ Expected for mobile |
| Release `device_preview` | ✅ Disabled via `kReleaseMode` |
| Android release signing | ⚠️ Still debug keystore in `build.gradle.kts` |

---

## Build & APK size

- Assets ~1.4MB; APK ~72MB likely from native deps (Firebase, Stripe, Google Sign-In) + multi-ABI fat APK.
- **Recommend:** `flutter build appbundle` for Play Store; `flutter build apk --split-per-abi` for direct APK distribution.

---

## Test baseline

```
flutter test → 107 passed
```

Coverage gaps: home `ProjectsSection`, `ProjectCard` perf helpers, `buildWhen` on major screens.

---

## Optimization checklist

See [optimization_checklist.md](optimization_checklist.md) for phased task tracking.

---

## Phase 1 validation

- [x] Project compiles (`dart analyze` — 0 errors)
- [x] All tests pass (107/107)
- [x] No behavior-changing code in Phase 1
- [x] Analysis report delivered
