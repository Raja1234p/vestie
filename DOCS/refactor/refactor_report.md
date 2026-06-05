# Refactor Report — Enterprise Clean Architecture

**Branch:** `refactor/enterprise-clean-architecture`  
**Date:** June 2026

---

## Summary

Structural refactor focused on **onboarding clarity** and **DI maintainability** without changing UI, APIs, or navigation behavior.

| Phase | Status | Deliverable |
|-------|--------|-------------|
| 0 | ✓ | Branch created |
| 1 | ✓ | Architecture audit + roadmap |
| 2 | ✓ | `project_detail_navigation.dart` + `ProjectDetailNavigation` class |
| 3 | Partial | Navigation barrel; full folder migration deferred (roadmap Wave E) |
| 4 | Planned | Large file splits in roadmap |
| 5 | Planned | Widget unification in roadmap |
| 6 | Planned | Naming pass on touched files |
| 7 | ✓ | Documented in DEPENDENCY_MAP |
| 8 | ✓ | `route_names.dart`, `route_extensions.dart`, `vestie_navigation.dart` |
| 9 | ✓ | Six `inject_*.dart` modules |
| 10 | ✓ | README links, FEATURE_MAP, DEPENDENCY_MAP |
| 11 | ✓ | 112/112 tests pass, 0 analyzer errors on changed paths |
| 12 | ✓ | This report + maintainability + technical debt docs |

---

## Code changes

### Dependency injection

- **Before:** Single `service_locator.dart` ~476 lines with all registration inline
- **After:** Facade ~287 lines + 6 domain inject modules (~30–120 lines each)

### Navigation naming

- **Before:** `project_detail_navigation_helpers.dart` / `ProjectDetailNavigationHelpers`
- **After:** `project_detail_navigation.dart` / `ProjectDetailNavigation`
- **18 consumer files** updated (imports + class references)

### New onboarding artifacts

- `FEATURE_MAP.md` — feature → folder → API → route
- `DEPENDENCY_MAP.md` — DI modules, services vs repositories
- `lib/core/navigation/vestie_navigation.dart` — barrel export
- `lib/app/router/route_extensions.dart` — typed `BuildContext` helpers

---

## Validation

```text
flutter test  → 112 passed
dart analyze  → 0 errors (di, router, navigation)
```

No visual or behavioral changes intended.

---

## Remaining work (roadmap)

See [refactoring_roadmap.md](refactoring_roadmap.md) Waves C–E:

- Split `project_detail_navigation.dart` (538 lines) by route group
- Split `app_shimmer.dart`, `member_detail_screen.dart`, flow screens
- Incremental feature folder migration (one feature per PR)
- Optional `AppEmptyState` / `AppSectionHeader` wrappers
