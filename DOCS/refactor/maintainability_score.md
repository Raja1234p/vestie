# Maintainability Score

**Branch:** `refactor/enterprise-clean-architecture`  
**Scale:** 1 (poor) → 5 (excellent)

---

## Category scores

| Category | Before | After | Notes |
|----------|--------|-------|-------|
| **Feature discoverability** | 2.5 | 4.0 | FEATURE_MAP + folder README guidance |
| **DI clarity** | 2.0 | 4.0 | inject_* modules by domain |
| **Navigation clarity** | 3.0 | 4.0 | Explicit navigation class + route extensions |
| **Naming consistency** | 3.5 | 4.0 | Removed “helpers” from primary navigation API |
| **File size discipline** | 2.5 | 2.5 | Large files documented; splits pending |
| **Test coverage** | 3.5 | 3.5 | 112 tests; DI modules untested (factory smoke optional) |
| **Documentation** | 3.0 | 4.5 | FEATURE_MAP, DEPENDENCY_MAP, audit, roadmap |

**Weighted overall:** **3.4 → 3.9 / 5**

---

## Onboarding time estimates

| Task | Before | After (target) |
|------|--------|----------------|
| Find wallet feature | 3–5 min | < 1 min (FEATURE_MAP) |
| Trace contribute API call | 5–10 min | 3–5 min (DEPENDENCY_MAP) |
| Add new route | 5 min | 3 min (AppRoutes + route_extensions) |
| Register new repository | 10 min (scroll 476-line file) | 3 min (correct inject_*.dart) |

---

## Success criteria progress

| Criterion | Met? |
|-----------|------|
| Find feature in 30 seconds | ✓ With FEATURE_MAP |
| Understand screen in 5 minutes | Partial — large screens still need splits |
| Modify feature without cross-impact | ✓ Role folders preserved |
| Trace UI → API | ✓ DEPENDENCY_MAP + clean layers |
| No AI required | Improving — docs close the gap |

---

## Next actions to reach 4.5+

1. Split top 5 files >400 lines (roadmap Phase 4)
2. Migrate one feature folder per sprint (roadmap Phase 3b)
3. Add DI smoke test (`ServiceLocator.init` in `test/`)
4. Add `lib/features/README.md`, `lib/user/README.md`, `lib/leader/README.md`
