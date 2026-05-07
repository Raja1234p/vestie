# What Needs To Be Fixed (API Integration)

This is the short, actionable checklist of **remaining fixes** from the latest audit.

---

## 1) Remove Stubbed Project Actions (Critical)

Fix these files so usecases return real repository results (not placeholders):

- `lib/features/project_detail/domain/usecases/project_actions_usecases.dart`

Current problems:

- multiple methods return `Right(null)` without calling backend
- invite flow returns `dummy_invite_code`

Must be real:

- open/extend/finalize closure voting
- resolve goal
- extend deadline
- complete project
- create invite
- member admin actions

---

## 2) Fix DI Wiring and Initialization Order (Critical)

File:

- `lib/core/di/service_locator.dart`

Current problems:

- `apiClient` usage before assignment risk
- duplicate stacks registered at same time (legacy + newer)

Required:

- initialize dependencies in safe order
- keep one production path per feature
- ensure route-wired blocs/usecases point to real implementations

---

## 3) Unify Duplicate API Stacks (Critical)

Features currently have parallel implementations that cause inconsistent runtime behavior:

- Project actions:
  - legacy: `project_actions_usecases.dart` + related datasource/repository
  - newer: separate action methods elsewhere
- Contributions:
  - legacy: `contribution_remote_data_source.dart` path
  - newer: `contributions_remote_data_source.dart` path

Required:

- choose one stack for runtime
- remove/retire unused duplicate path
- avoid mixed route wiring

---

## 4) Complete Week 4 Contribution Payload in Active Route Flow

Active contribute route must submit full Week 4 body from current UI flow:

- `projectId`
- `membershipId`
- `walletId`
- `amount`
- `currency`
- `externalReference` (nullable)
- `confirmNonRefundable`

Also ensure:

- config/preview/confirm use one consistent datasource + repository chain
- preview values drive final breakdown (no hardcoded fee logic)

---

## 5) Finalize Remaining Endpoint Coverage

Verify active runtime integration for:

- `POST /projects/join`
- `GET /projects/invites/{inviteCode}/preview`
- borrow decision endpoint (leader approve/reject request) once backend contract is confirmed
- `PATCH /projects/{id}/members/{userId}/borrow-limit`
- `POST /projects/{id}/investment/external` (if screen/action exists)

---

## 6) Finish Endpoint Centralization

Still not fully centralized in all feature datasources.

Files still needing endpoint cleanup:

- `lib/features/projects/data/datasources/project_remote_data_source.dart`
- `lib/features/profile/data/datasources/profile_remote_data_source.dart`

Required:

- use `ApiConstants.projects`, `ApiConstants.me`, etc.
- avoid endpoint root strings outside `ApiConstants`

---

## 7) Analyzer Cleanup

Current status: no compile errors, but warnings/info remain.

Required:

- clear unused imports
- fix `network_info.dart` dead/unrelated type checks
- re-run `flutter analyze` until clean target is reached

---

## Done Criteria

This work is done when all are true:

- no stub/dummy API responses in active usecases
- one clean runtime stack per feature (no duplicate conflicting paths)
- active contribute flow matches Week 4 payload contract
- role-gated flows keep same UI and use real backend actions
- `flutter analyze` returns zero errors (and ideally zero warnings)

