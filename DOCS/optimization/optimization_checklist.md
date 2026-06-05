# Production Optimization Checklist

Track progress on branch `production-optimization`. Each phase must compile, pass tests, and preserve UI/UX.

## Phase 1 — Analysis & Baseline
- [x] Project structure analyzed
- [x] Performance bottlenecks identified
- [x] Rebuild / memory / network / startup reviewed
- [x] `dart analyze` + `flutter test` baseline recorded
- [x] Analysis report (`phase1_analysis_report.md`)

## Phase 2 — Static Code Quality
- [ ] Remove dead code (`test_auth_flow.dart`)
- [ ] Fix unused / unnecessary imports (analyzer warnings)
- [ ] Null-aware / lint info fixes where safe

## Phase 3 — Widget Rebuild Optimization
- [ ] `buildWhen` on `HomeBloc` / `HomeSectionsCubit`
- [ ] `buildWhen` on `DiscoverCubit` outer builder
- [ ] `AppTextStyles` for hot-path typography (home section title)

## Phase 4 — Memory Optimization
- [ ] `cacheWidth` / `cacheHeight` on `ProjectCard` images
- [ ] `cacheWidth` / `cacheHeight` on notification row images
- [ ] Verify controller `dispose` on flow screens

## Phase 5 — Rendering & Scrolling
- [ ] `ProjectsSection` → lazy `ListView.builder` (shrinkWrap)
- [ ] `RepaintBoundary` on `ProjectCard`
- [ ] `user_project_detail_screen` → `SliverChildBuilderDelegate`

## Phase 6 — Network & API
- [ ] Document prefetch dedup pattern
- [ ] `buildWhen` on notifications to skip silent-refresh-only rebuilds

## Phase 7 — Startup
- [ ] Move `device_preview` to `dev_dependencies`
- [ ] Add `main_dev.dart` entry for debug previews

## Phase 8 — Build & Release
- [ ] Release build script (`split-per-abi`, app bundle)
- [ ] Android `proguard-rules.pro` placeholder for plugins

## Phase 9 — Security & Hardening
- [ ] `kDebugMode` guard on `debugPrint` in services
- [ ] Confirm no debug artifacts in release path

## Phase 10 — Testing
- [ ] Widget test: `ProjectsSection` lazy list
- [ ] Unit test: `HomeSectionsCubit` / `buildWhen` helpers
- [ ] All existing tests pass

## Phase 11 — Production Audit
- [ ] `dart analyze` — 0 errors, 0 warnings
- [ ] Final optimization report
- [ ] Production readiness checklist sign-off
