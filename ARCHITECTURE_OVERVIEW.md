# Vestie — Architecture Overview

**Goal:** A new developer can understand how Vestie is built in ~30 minutes.  
**Audience:** Flutter engineers joining the project.  
**Last aligned with code:** June 2026 (`maintainability-wave` branch)

---

## 1. What Vestie is

Vestie is a **collaborative group savings** Flutter app. Users create or join **projects** (vacation, emergency, investment), contribute from a personal **wallet**, borrow from group pots (vacation/emergency), and manage money through **Stripe** (cards, KYC, bank link).

Product detail: [`DOCS/project_scope.md`](DOCS/project_scope.md)

---

## 2. Repository layout (find any feature in &lt;30 seconds)

```text
lib/
├── main.dart, bootstrap.dart, main_dev.dart   # Entry points
├── app/                                         # GoRouter, MainApp, route args
├── core/                                        # API, DI, theme, realtime, shared widgets
├── features/                                    # Shared modules (all roles)
├── user/features/                               # Member-only screens & flows
└── leader/features/                             # Leader-only screens & flows
```

| Question | Where to look |
|----------|---------------|
| Route path constant | `lib/app/router/app_routes.dart` |
| Screen registration | `lib/app/router/app_router.dart`, `route_groups/` |
| Feature index | [`FEATURE_MAP.md`](FEATURE_MAP.md) |
| DI registration | `lib/core/di/inject_*.dart`, [`DEPENDENCY_MAP.md`](DEPENDENCY_MAP.md) |
| End-to-end flows | [`PROJECT_FLOW_MAP.md`](PROJECT_FLOW_MAP.md) |
| Role-specific UI | `user/features/` vs `leader/features/` vs shared `features/` |

### Role separation

| Role | Code folder | Dashboard entry |
|------|-------------|-----------------|
| **Shared** | `lib/features/` | Splash, auth, wallet, invites, project detail shell |
| **Member** | `lib/user/features/` | Home, Discover, Contribute, Borrow, VFF |
| **Leader** | `lib/leader/features/` | Create wizard, join/borrow moderation, distribute funds |

`ProjectDetailEntity.isModeratorView` / `viewerRole` decides which menus and routes appear on detail screens — not separate apps.

---

## 3. Layered architecture

Every live API feature follows **Clean Architecture** with **BLoC/Cubit** presentation:

```text
Screen/Widget
    ↓ events / reads state
Cubit or Bloc
    ↓
UseCase (domain)
    ↓
Repository (interface in domain, impl in data)
    ↓
RemoteDataSource → BaseApiClient / DioClient
```

**Example trace (wallet balance):**

`WalletScreen` → `WalletCubit` → `GetWalletUseCase` → `WalletRepository` → `WalletRemoteDataSource`

**Example trace (contribute):**

`ContributeFlowScreen` → `ContributeBloc` → `ConfirmContributionUseCase` → `ContributionRepository`

---

## 4. Dependency injection

- **Facade:** `ServiceLocator.instance` (`lib/core/di/service_locator.dart`)
- **Modules:** `inject_core.dart`, `inject_auth.dart`, `inject_project.dart`, `inject_wallet.dart`, `inject_notifications.dart`, `inject_user.dart`
- **Init order:** core → auth → project → wallet → notifications → user

Route-level `BlocProvider` factories call `ServiceLocator.instance.create*Bloc()` / `create*Cubit()`.

`MainApp` holds long-lived cubits (`WalletCubit`, `CreateProjectCubit`) so tab switches and the leader wizard survive navigation.

---

## 5. Navigation

- **Router:** `go_router` — `AppRouter` in `lib/app/router/`
- **Paths:** Always `AppRoutes.*` — never raw strings in widgets
- **Typed extras:** Many routes require `GoRouterState.extra` (`ProjectDetailRouteArgs`, `ProjectWalletFlowArgs`, …). Missing extra → route-not-found scaffold
- **Helpers:** `ProjectDetailNavigation`, `openProjectFromCard`, `VestieNavigation` barrel

### Post-auth hub

`DashboardScreen` (`/dashboard`) = `IndexedStack` + bottom nav:

| Tab | Screen | Primary API |
|-----|--------|-------------|
| 0 Home | `HomeScreen` | `GET /projects?scope=mine` |
| 1 Discover | `DiscoverScreen` | `GET /projects?scope=discover` |
| 2 + | Leader create sheet | `POST /projects` + launch |
| 3 Wallet | `WalletScreen` | `/wallet` |
| 4 Profile | `ProfileScreen` | `/users/me` |

---

## 6. State management

| Pattern | Used for |
|---------|----------|
| **Cubit** | Forms, tabs, simple async (wallet, profile, discover filters) |
| **Bloc** | Multi-step flows with events (auth, project detail, contribute, voting) |
| **Equatable** | State/event equality |

Global session: `AppAuthSession` (refresh listenable on GoRouter).  
Realtime: `ProjectsSignalRService`, `WalletSignalRService` under `lib/core/realtime/`.

---

## 7. Network & auth

```text
DioClient / BaseApiClient
    → AuthInterceptor (Bearer from flutter_secure_storage)
    → Error mapping → Failure types in repositories
```

- **DioClient:** Auth, borrow, legacy project detail datasource
- **BaseApiClient:** Wallet, VFF, notifications, contributions, project actions

Environment base URL: `ApiConstants` / build flavors.

---

## 8. Money & compliance stack

| Concern | Location |
|---------|----------|
| Wallet balance / ledger | `wallet/` |
| Deposit (Stripe PaymentSheet) | `wallet/` + `core/stripe/` |
| Withdraw preview + payout | `wallet/` + `features/bank_accounts/` |
| Payment methods (SetupIntent) | `features/payment_methods/` |
| KYC (Stripe Identity) | `features/kyc/` |
| Stripe config | `features/stripe/` |

Deep-link returns (`vestie://kyc/*`, `vestie://bank/*`) are handled outside GoRouter via `app_links`.

---

## 9. Project domain

| Category | Detail route | Borrow | Co-leader |
|----------|--------------|--------|-----------|
| Vacation | `/project/detail` | Yes | Yes |
| Emergency | `/project/detail` | Yes | Yes |
| Investment | `/project/investment-detail` | No | No |

Shared detail entity and bloc: `features/project_detail/`.  
Member-only vote/returns UI: `user/features/project_detail/`.  
Leader moderation: `leader/features/project_detail/`.

---

## 10. Testing & quality

```bash
flutter pub get
dart format .
flutter analyze
flutter test
```

Release script: [`scripts/build_release.ps1`](scripts/build_release.ps1)

Pre-commit standards: [`.cursor/rules/pre_commit.mdc`](.cursor/rules/pre_commit.mdc)

---

## 11. Related docs (read in this order)

1. [`README.md`](README.md) — setup & folder tree
2. **This file** — architecture mental model
3. [`FEATURE_MAP.md`](FEATURE_MAP.md) — where code lives
4. [`PROJECT_FLOW_MAP.md`](PROJECT_FLOW_MAP.md) — auth, wallet, project, payment, KYC flows
5. [`DEPENDENCY_MAP.md`](DEPENDENCY_MAP.md) — DI and services
6. [`DOCS/architecture_flows.md`](DOCS/architecture_flows.md) — extended flow taxonomy & join paths
7. Per-feature `feature_overview.md` under each feature root folder

---

## 12. Deferred structural work

Large folder migration (~794 files) is **intentionally deferred**. Migrate one feature per PR when ready. See `.cursor/rules/production_scope.mdc`.
