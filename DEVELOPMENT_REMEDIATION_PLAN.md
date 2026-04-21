# Vestie Development Remediation Plan

## Goal
Establish a stable baseline so all upcoming feature work follows project rules:
- no hardcoding (use constants/tokens)
- no `setState` for app state (use Bloc/Cubit)
- validation only in `core/utils/validation_utils.dart`
- consistent shared UI components
- safe `go_router` navigation
- keep files modular (target under ~150 lines where practical)

## Phase 1 — Validation and Shared Component Baseline (Highest Priority)

### 1. Unify validation source
- **Fix**
  - Migrate all remaining validation usage to `core/utils/validation_utils.dart`
  - Remove duplicate overlap from `core/utils/validators.dart`
  - Update `core/extensions/string_extensions.dart` to reference `ValidationUtils`
- **Why**
  - Prevent inconsistent rules/messages and duplicate logic drift
- **Done when**
  - Only one validation utility remains active
  - No imports/usages of deprecated validator paths

### 2. Consolidate duplicate common widgets
- **Fix**
  - Keep one canonical implementation each for:
    - `AppText`
    - `AppTextField`
    - `AppLoader`
  - Remove or re-export duplicate copies to prevent import ambiguity
- **Why**
  - Avoid inconsistent behavior and styling across screens
- **Done when**
  - Each common widget has one source of truth
  - Imports across features point to canonical paths only

## Phase 2 — Hardcoding Cleanup and Token Consistency

### 3. Replace remaining raw colors/strings/sizing literals
- **Fix**
  - Migrate raw UI literals in flagged screens/widgets to `AppColors`, `AppStrings`, theme tokens
  - Prioritize:
    - `features/auth/presentation/pages/agreement_screen.dart`
    - `features/profile/presentation/pages/key_guidelines_screen.dart`
    - `core/widgets/common/app_transaction_item.dart`
    - `features/home/presentation/widgets/project_card.dart`
- **Why**
  - Keeps styling and copy centrally managed and scalable
- **Done when**
  - Feature UI avoids direct hardcoded colors/labels (except justified edge cases)

## Phase 3 — Navigation Safety and Wizard Stability

### 4. Guard `go_router` extras and avoid unsafe casts
- **Fix**
  - Replace direct `state.extra as Type` casts in router with guarded parsing/fallback flow
  - Ensure all route entry points handle missing/invalid extras safely
- **Why**
  - Prevent runtime crashes during deep-links and alternate navigation paths
- **Done when**
  - Router paths fail gracefully for invalid extras

### 5. Stabilize multi-step edit/review flows
- **Fix**
  - Re-check create-project edit stack transitions and back behavior
  - Verify Details -> Borrowing -> Review edit cycle and manual back gestures
- **Why**
  - Wizard navigation regressions are high-impact
- **Done when**
  - All edit and non-edit step transitions are deterministic and tested

## Phase 4 — File Modularity and Maintainability

### 6. Split oversized files into focused widgets/helpers
- **Fix**
  - Refactor large UI files (starting with `project_card.dart` and create-project pages)
  - Extract repeated UI blocks and formatting helpers
- **Why**
  - Improves readability, testability, and review speed
- **Done when**
  - Files are reasonably modular and responsibilities are separated

## Execution Order
1. Validation unification
2. Shared widget consolidation
3. Hardcoding/token cleanup
4. Router safety guards
5. Wizard flow regression pass
6. Large-file refactors

## Verification Checklist (Run after each phase)
- `flutter analyze` passes with zero new issues
- Touched feature flows are manually smoke-tested
- No rule regressions introduced (validation, tokens, navigation, state management)

## Deliverables
- Incremental PR-style commits by phase
- Short change log per phase (files changed + behavior impact)
- Final audit summary confirming compliance baseline for next feature development
