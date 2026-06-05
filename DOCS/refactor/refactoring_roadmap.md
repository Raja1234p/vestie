# Refactoring Roadmap — Enterprise Maintainability

**Principle:** Structural changes only. Zero UI, API, navigation behavior, or business logic changes per phase.

---

## Wave overview

| Wave | Phases | Focus | Risk |
|------|--------|-------|------|
| **A** | 0–1 | Branch, audit, docs | None |
| **B** | 8–9–10 | Routes, DI, developer docs | Low |
| **C** | 2–4 | Naming, file splits | Low–medium |
| **D** | 5–6 | Widget extraction, naming in hot paths | Medium |
| **E** | 3 | Folder migration | **High** — multi-sprint |
| **F** | 11–12 | Test gate, production validation | Low |

---

## Phase 0 — Branch ✓

`refactor/enterprise-clean-architecture` from `production-optimization`.

---

## Phase 1 — Architecture audit ✓

Deliverables: `architecture_audit.md`, this roadmap.

---

## Phase 2 — File naming (Wave C)

**Sprint 2.1 (immediate)**

- [x] `project_detail_navigation_helpers.dart` → `project_detail_navigation.dart`
- [ ] `app_permission_helper.dart` → `app_permission_handler.dart` (optional)
- [ ] Align `contribution_repository` vs `contributions_repository` naming in docs

**Sprint 2.2**

- Audit `*_usecase.dart` vs `*_use_case.dart` — standardize on `*_use_case.dart` for new files only (avoid mass rename churn).

---

## Phase 3 — Folder structure (Wave E — deferred bulk move)

**Do not** mass-move 794 files in one PR. Use **incremental migration**:

### Target model (long-term)

```text
lib/features/<feature>/{data,domain,presentation,widgets}/
lib/leader/<feature>/...
lib/user/<feature>/...
```

### Current model (keep until Wave E)

```text
lib/features/     # shared
lib/user/features/
lib/leader/features/
```

### Phase 3a (safe, now)

1. Add `lib/core/navigation/` barrel exporting router + routes + extensions
2. Add `README.md` in `lib/features/`, `lib/user/`, `lib/leader/` explaining ownership
3. Map each feature to target folder in `FEATURE_MAP.md`

### Phase 3b (later sprints)

| Sprint | Move |
|--------|------|
| E1 | `user/features/vff` → `features/vff` (update imports) |
| E2 | `user/features/home` + `discover` → `features/discover` package |
| E3 | Consolidate `leader/features` under `features/project/leader/` |

Each sprint: one feature, full test pass, single PR.

---

## Phase 4 — Class responsibility (Wave C)

Priority splits (lines > guideline):

| File | Split into |
|------|------------|
| `project_detail_navigation.dart` | `project_detail_pop_navigation.dart`, `project_detail_leader_navigation.dart`, `project_detail_member_navigation.dart` |
| `member_detail_screen.dart` | Keep screen thin; move sections to existing `member_detail_sections.dart` |
| `member_detail_cubit.dart` | `member_detail_co_leader_actions.dart`, `member_detail_vff_actions.dart` |
| `app_shimmer.dart` | `app_shimmer_project.dart`, `app_shimmer_wallet.dart`, `app_shimmer_vff.dart` |
| `contribute_flow_screen.dart` | Step widgets per wizard step |
| `borrow_flow_screen.dart` | Step widgets per wizard step |

---

## Phase 5 — Widget extraction (Wave D)

**Already exist — use consistently:**

| Proposed | Existing |
|----------|----------|
| `AppErrorState` | `AppErrorView` |
| `AppLoadingState` | `AppShimmer`, `AppLoadingOverlay` |
| `AppConfirmationDialog` | `AppActionDialog` |
| `AppUserAvatar` | `AppNetworkAvatar`, `AppAvatarCircle` |

**Create (thin wrappers, no visual change):**

- `AppSectionHeader` — delegate to `UserVffSectionHeader` / discover patterns
- `AppEmptyState` — config wrapper over `HomeEmptyView` layout

---

## Phase 6 — Naming (Wave D)

- Enforce in **new** code and **touched** files only
- Ban single-letter closure params in public APIs
- Prefer `walletBalance` over `data` in repository return types (already mostly done)

---

## Phase 7 — Repository vs service (document + enforce)

| Layer | Location | Examples |
|-------|----------|----------|
| Repository | `features/*/data/repositories/` | `WalletRepositoryImpl` |
| Service | `core/services/`, `core/realtime/` | `FcmPushService`, `ProjectsSignalRService` |
| Prefetch | `core/services/*_prefetch.dart` | Not repositories |

**Rule:** No `BuildContext` in repositories (already satisfied).

---

## Phase 8 — Route organization (Wave B)

- [x] `app_routes.dart` — canonical (keep)
- [ ] `route_names.dart` — alias/export layer for onboarding
- [ ] `route_extensions.dart` — `BuildContext` helpers wrapping `go`/`push` with `AppRoutes`
- [ ] `lib/core/navigation/vestie_router.dart` — barrel export

---

## Phase 9 — DI cleanup (Wave B)

Split `service_locator.dart` into:

```text
lib/core/di/
├── service_locator.dart      # Facade + factories only
├── inject_core.dart
├── inject_auth.dart
├── inject_project.dart
├── inject_wallet.dart
├── inject_vff.dart
└── inject_notifications.dart
```

---

## Phase 10 — Documentation (Wave B)

- [ ] Update root `README.md`
- [ ] `FEATURE_MAP.md`
- [ ] `DEPENDENCY_MAP.md`

---

## Phase 11 — Test gate (every wave)

```bash
flutter clean && flutter pub get
dart analyze
dart format .
flutter test
```

---

## Phase 12 — Production validation

- `refactor_report.md`
- `maintainability_score.md`
- `technical_debt_report.md`

---

## Success metrics

| Metric | Before | Target |
|--------|--------|--------|
| `service_locator.dart` lines | ~476 | <120 (facade only) |
| Navigation helper lines | 538 | <200 per file |
| Time to find feature | ~2–5 min | <30 sec (with FEATURE_MAP) |
| Analyzer errors | 0 | 0 |
| Test pass rate | 112/112 | 100% |

---

## Explicit non-goals

- Changing API request/response models
- Visual redesign
- Altering Stripe / SignalR / Firebase / KYC / deep link behavior
- Big-bang folder move without per-feature PRs
