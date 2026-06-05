# Production Optimization Checklist

Track progress on branch `production-optimization`. Each phase must compile, pass tests, and preserve UI/UX.

## Phase 1 — Analysis & Baseline
- [x] Project structure analyzed
- [x] Performance bottlenecks identified
- [x] Rebuild / memory / network / startup reviewed
- [x] `dart analyze` + `flutter test` baseline recorded
- [x] Analysis report (`phase1_analysis_report.md`)

## Phase 2 — Static Code Quality
- [x] Remove dead code (`test_auth_flow.dart`)
- [x] Fix unused / unnecessary imports (analyzer warnings)
- [x] Null-aware / lint info fixes where safe

## Phase 3 — Widget Rebuild Optimization
- [x] `buildWhen` on `HomeBloc` / `HomeSectionsCubit`
- [x] `buildWhen` on `DiscoverCubit` outer builder
- [x] `AppTextStyles` for hot-path typography (home section title)

## Phase 4 — Memory Optimization
- [x] `cacheWidth` / `cacheHeight` on `ProjectCard` images
- [x] `cacheWidth` / `cacheHeight` on notification row images
- [x] Verify controller `dispose` on flow screens (existing — no regressions)

## Phase 5 — Rendering & Scrolling
- [x] `ProjectsSection` → lazy `ListView.builder` (shrinkWrap)
- [x] `RepaintBoundary` on `ProjectCard`
- [x] `user_project_detail_screen` → `SliverChildBuilderDelegate`

## Phase 6 — Network & API
- [x] Prefetch cache short-circuit (payment methods, bank accounts)
- [x] Document prefetch dedup pattern (`network_prefetch.md`)
- [x] `buildWhen` on notifications screen

## Phase 7 — Startup
- [x] Extract `AppBootstrap.run()` (`bootstrap.dart`)
- [x] Production `main.dart` without DevicePreview wrapper
- [x] `main_dev.dart` debug entry (`flutter run -t lib/main_dev.dart`)

## Phase 8 — Build & Release
- [x] Release build script (`scripts/build_release.ps1`)
- [x] Android `proguard-rules.pro` for Flutter / Firebase / Stripe
- [x] `device_preview` moved to `dev_dependencies`

## Phase 9 — Security & Hardening
- [x] `kDebugMode` guard on `debugPrint` in FCM / SignalR services
- [x] Production entry uses `main.dart` only

## Phase 10 — Testing
- [x] Unit test: `HomeSectionsCubit`
- [x] Widget test: `ProjectsSection` lazy list
- [x] All existing tests pass

## Phase 11 — Production Audit
- [x] `dart analyze` — 0 errors
- [x] Final optimization report (`phase11_final_report.md`)
- [x] Production readiness checklist sign-off
