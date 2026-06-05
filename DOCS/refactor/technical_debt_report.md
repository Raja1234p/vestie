# Technical Debt Report

**Date:** June 2026  
**Post-refactor snapshot**

---

## Resolved in this branch

| Item | Resolution |
|------|------------|
| Monolithic DI registration | Split into `inject_*.dart` |
| Ambiguous navigation helper name | Renamed to `ProjectDetailNavigation` |
| Missing feature index | `FEATURE_MAP.md` |
| Missing DI documentation | `DEPENDENCY_MAP.md` |

---

## Open — high priority

| Debt | Location | Risk | Effort |
|------|----------|------|--------|
| 538-line navigation file | `project_detail_navigation.dart` | Hard to modify safely | Medium — split by leader/member/investment |
| 635-line shimmer | `app_shimmer.dart` | Merge conflicts | Medium |
| Dual repo naming | `contribution_repository` vs `contributions_repository` | Confusion | Low — document + deprecate one |
| Three top-level feature roots | `features/`, `user/`, `leader/` | Onboarding friction | High — incremental migration |

---

## Open — medium priority

| Debt | Location | Notes |
|------|----------|-------|
| `app_strings.dart` 1272 lines | `core/constants/` | Acceptable; optional domain split |
| `member_detail_cubit.dart` 434 lines | project_detail | Split action groups |
| `contribute_flow_screen.dart` 489 lines | user/contribute | Extract step widgets |
| `borrow_flow_screen.dart` 470 lines | user/borrow | Extract step widgets |
| FCM → screen deep nav incomplete | `fcm_push_service.dart` | Product gap, not refactor |
| `AppRoutes.cardDetail` unregistered | `app_routes.dart` | Dead constant |

---

## Open — low priority

| Debt | Notes |
|------|-------|
| `*_usecase.dart` vs `*_use_case.dart` | Standardize on new files only |
| `formatters.dart` generic name | Rename when touched |
| Duplicate empty-state layouts | Optional `AppEmptyState` wrapper |
| README says “Dio stubbed” | Outdated — update README (done partially) |

---

## Explicit non-debt (working as designed)

- Role split `user/` vs `leader/` — intentional until Wave E migration
- UI-only member fund storyboard — documented in FEATURE_MAP
- `IndexedStack` dashboard tabs — preserves tab state

---

## Recommended sprint order

1. Split `project_detail_navigation.dart` (3 files)
2. Split `app_shimmer.dart` by domain
3. `member_detail_screen` + cubit split
4. VFF folder migration (single PR + full QA)
