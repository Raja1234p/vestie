# Vestie — Flutter Fintech App

A collaborative group savings app built in Flutter where users create and join savings projects (vacations, emergencies, investments). Full Figma-accurate UI with Clean Architecture + BLoC/Cubit.

---

## Quick Start

```bash
flutter pub get
flutter run
```

> Requires Flutter 3.x · Dart 3.x · Android SDK 21+ · iOS 14+

---

## Documentation (start here)

| Document | Purpose |
|----------|---------|
| **[`DOCS/HANDOFF.md`](DOCS/HANDOFF.md)** | **Mandatory E2E resume** — current branch, shipped work, features, flows, files |
| **[`APP_GUIDE.md`](APP_GUIDE.md)** | Roles, voting flow, money flows, completed projects, key files |
| [`ARCHITECTURE_OVERVIEW.md`](ARCHITECTURE_OVERVIEW.md) | 30-minute architecture onboarding |
| [`FEATURE_MAP.md`](FEATURE_MAP.md) | Feature → folder → API index |
| [`PROJECT_FLOW_MAP.md`](PROJECT_FLOW_MAP.md) | Step-by-step flow traces (auth, wallet, project, leader, member, VFF, KYC) |
| [`DEPENDENCY_MAP.md`](DEPENDENCY_MAP.md) | Dependency injection map |
| [`DOCS/project_scope.md`](DOCS/project_scope.md) | Full product & technical scope |
| [`DOCS/architecture_flows.md`](DOCS/architecture_flows.md) | Extended routes, join paths, project types |
| [`DOCS/group_vacation_emergency_member_flow.md`](DOCS/group_vacation_emergency_member_flow.md) | Member vacation/emergency screen list |
| [`DOCS/api_integration_plan.md`](DOCS/api_integration_plan.md) | API integration (Weeks 4, 5, 7, 8, 10–11) |
| [`DOCS/qa/README.md`](DOCS/qa/README.md) | QA runbooks before release |
| `feature_overview.md` | Per-feature notes inside each `lib/**/features/` folder |
| `.cursor/rules/*.mdc` | Engineering rules for AI and team (`handoff.mdc` requires reading HANDOFF first) |

---

## Tech Stack

| Concern | Package |
|---------|---------|
| State management | `flutter_bloc`, `equatable` |
| Navigation | `go_router` |
| UI scaling | `flutter_screenutil` (390 × 844 design base) |
| Typography | `google_fonts` — Inter throughout |
| SVG rendering | `flutter_svg` |
| Secure storage | `flutter_secure_storage` |
| HTTP | `dio` + `BaseApiClient` |
| Payments | Stripe PaymentSheet |
| Realtime | SignalR (`/hubs/wallet`, `/hubs/projects`) |
| Push | Firebase FCM |

---

## Build & release

```bash
flutter pub get
flutter analyze
flutter test
flutter run                    # production entry: lib/main.dart
flutter run -t lib/main_dev.dart   # DevicePreview (dev only)
flutter build apk --release
```

Release script: [`scripts/build_release.ps1`](scripts/build_release.ps1)

---

## Repository layout

```text
lib/
├── app/              # MainApp, GoRouter, AppRoutes
├── core/             # API, DI, theme, shared widgets
├── features/         # Shared modules (auth, wallet, project_detail, success_vote, …)
├── leader/features/  # Group leader: create wizard, moderation, voting monitor
└── user/features/    # Member: home, discover, contribute, borrow, VFF, …
```

**Roles:** Group Leader → `leader/features/` · Member → `user/features/` · Shared → `features/` + `core/`

See [`APP_GUIDE.md`](APP_GUIDE.md) §2–3 for the full role and file map.

---

## Pre-release

Before store release, run QA per [`DOCS/qa/manual_test_runbook.md`](DOCS/qa/manual_test_runbook.md) and the audit snapshot in [`APP_GUIDE.md`](APP_GUIDE.md) §13.

---

## Engineering rules

1. **No hardcoding** — `AppStrings`, `AppColors`, `AppAssets`, `AppRoutes`, `ApiConstants`
2. **State** — Cubit/Bloc for business logic; no `setState` for API flows
3. **Navigation** — `go_router` + `AppRoutes` only
4. **Layers** — presentation → domain ← data (no widgets → Dio)
5. **Feedback** — `AppToast` (actions), `AppErrorView` (load fail), loaders per architecture rules

Full checklist: `.cursor/rules/pre_commit.mdc` · `.cursor/rules/architecture.mdc`
