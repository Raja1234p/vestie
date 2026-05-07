# Week 4 API Audit Fix Plan (File-by-File)

This plan translates the audit findings into an execution checklist to reach full Week 4 compliance **without changing existing UX flow**.

Primary goals:

1. remove stub/duplicate API stacks
2. ensure route-wired flows use real Week 4 payloads
3. centralize endpoint usage with `ApiConstants`
4. keep all current screens/buttons/navigation unchanged

---

## 1) High-Risk Issues to Fix First

## A. Replace stubbed project-actions stack (critical)

Current files contain stubbed success returns and dummy values:

- `lib/features/project_detail/domain/usecases/project_actions_usecases.dart`
- `lib/features/project_detail/data/datasources/project_actions_remote_data_source.dart`
- `lib/features/project_detail/data/repositories/project_actions_repository_impl.dart`

### Required action

- Replace stub implementations with real calls through `DioClient`-based remote datasource.
- Ensure these endpoints are truly invoked:
  - `POST /projects/{id}/invites`
  - `POST /projects/{id}/closure-voting/open`
  - `POST /projects/{id}/closure-voting/extend`
  - `POST /projects/{id}/closure-voting/finalize`
  - `POST /projects/{id}/goal/resolve`
  - `POST /projects/{id}/deadline/extend`
  - `POST /projects/{id}/complete`
  - `POST/DELETE /members/{userId}/co-leader`
  - `DELETE /members/{userId}`
  - `POST /members/{userId}/defaulted`
  - `POST /members/{userId}/remove-non-repayment`

---

## B. Fix ServiceLocator initialization order and stack selection (critical)

File:

- `lib/core/di/service_locator.dart`

### Current risk

- `apiClient` is used before being initialized.
- duplicate contribution and project-action stacks coexist.

### Required action

- Initialize `apiClient` before any class that depends on it.
- Pick one production stack only:
  - prefer `DioClient` + Week4 datasource stack already used by newer features.
- Remove/stop wiring legacy stub stacks from active routes.

---

## C. Unify route-wired project detail + moderation with one consistent action stack

Files:

- `lib/features/project_detail/presentation/pages/project_detail_screen.dart`
- `lib/features/project_detail/presentation/pages/investment_project_detail_screen.dart`
- `lib/features/project_detail/presentation/pages/join_requests_screen.dart`
- `lib/features/project_detail/presentation/pages/member_detail_screen.dart`
- `lib/features/project_detail/presentation/pages/member_penalty_action_screen.dart`
- `lib/features/project_detail/presentation/navigation/project_detail_navigation_helpers.dart`

### Required action

- Keep UI identical.
- Ensure all leader actions use non-stub usecases tied to real HTTP calls.
- Validate that join approve/reject uses actual membership id semantics from backend.

---

## 2) Week 4 Contribution Flow Compliance Fix

Current active route uses legacy contribution pipeline with simplified payload.

Affected files:

- `lib/app/router/route_groups/project_routes.dart`
- `lib/features/contribute/presentation/pages/contribute_flow_screen.dart`
- `lib/features/contributions/presentation/bloc/contribute_bloc.dart`
- `lib/features/contributions/data/datasources/contribution_remote_data_source.dart`
- `lib/features/contributions/data/repositories/contribution_repository_impl.dart`
- `lib/features/contributions/domain/value_objects/contribution_flow_models.dart`

### Required action

- Keep same 3-step UI (Amount -> Confirm -> Success).
- Ensure active submission path sends full Week 4 shape:
  - `projectId`
  - `membershipId`
  - `walletId`
  - `amount`
  - `currency`
  - `externalReference` (nullable)
  - `confirmNonRefundable`
- Use `GET /contributions/projects/{projectId}/config` for real config constraints.
- Use preview response values for fee/total instead of local hardcoded percentages.

---

## 3) Endpoint Centralization Cleanup (`ApiConstants`)

Goal: avoid manual `ApiConstants.baseUrl + '/...'` construction in feature data layers.

Files to refactor:

- `lib/features/projects/data/datasources/project_remote_data_source.dart`
- `lib/features/contributions/data/datasources/contribution_remote_data_source.dart`
- `lib/features/project_detail/data/datasources/voting_remote_data_source.dart`
- `lib/features/project_detail/data/datasources/project_actions_remote_data_source.dart`
- `lib/features/profile/data/datasources/profile_remote_data_source.dart`

### Required action

- Use `ApiConstants.projects`, `ApiConstants.contributions`, `ApiConstants.me`, etc.
- Build path suffixes from those constants, not raw endpoint roots.

---

## 4) Role-Gating and Flow Verification Targets

Reference docs:

- `DOCS/user_leader_flow_all_screens.md`
- `DOCS/api_integration_week4_screen_mapping.md`

### Must stay true

- `project.isLeader` governs leader-only controls.
- User view remains contribute/borrow oriented.
- Leader view keeps `LeaderActionMenu` and moderation flows.
- No UI layout/order changes.

### Add verification checks

- Joined vs not-joined state behavior for action CTAs.
- `viewerMembership.role` and `viewerMembership.membershipId` mapping validity.
- Borrow limit propagation to borrow flow.

---

## 5) Remaining Endpoint Coverage Checklist

Confirm active integration for each:

- [ ] `POST /projects/join`
- [ ] `GET /projects/invites/{inviteCode}/preview`
- [ ] borrow-request leader decision endpoint (once contract finalized)
- [ ] `PATCH /projects/{id}/members/{userId}/borrow-limit`
- [ ] `POST /projects/{id}/investment/external` (if corresponding UI exists)

---

## 6) Analyzer Cleanliness Target

Current analyze has warnings/info issues.

### Minimum cleanup pass

- remove unused imports
- resolve `network_info.dart` dead/unrelated type checks
- keep code style warnings low in touched files

Final required command:

- `flutter analyze`
- target: **0 errors**, and ideally **0 warnings** in changed modules

---

## 7) Suggested Execution Order

1. Fix `ServiceLocator` initialization order and active stack selection.
2. Replace stub project-actions usecases/datasource/repository with real implementations.
3. Rewire contribution route path to full Week 4 request model.
4. Centralize endpoint usage to `ApiConstants`.
5. Run role-flow regression checks (User vs Leader screens).
6. Run `flutter analyze`.

---

## 8) Definition of Done

Done means all are true:

- No stubbed/dummy usecase responses for active flows.
- Route-triggered actions hit real Week 4 endpoints.
- Contribution active flow uses config/preview/confirm with full payload.
- User/Leader behavior matches existing screen flow doc.
- `flutter analyze` has 0 compile errors.

