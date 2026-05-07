# Vestie API Integration Guide (Screen-by-Screen, Week 4)

This document maps backend APIs from `api_documentation_week4.md` to the existing Flutter routes/screens so another developer can integrate without extra clarification.

- Backend reference: `c:\Users\hp\source\repos\Vestie-Backend2\api_documentation_week4.md`
- App routes: `lib/app/router/app_routes.dart`
- UI flow references: `DOCS/user_leader_flow_all_screens.md`, `DOCS/ui_flow_grouped_clickable_map.md`

---

## 1) Integration Standards (Apply Everywhere)

### 1.1 Base config

- Base URL: `/api/v1` (resolved via environment in app config).
- Content type: `application/json`.
- Auth header for protected APIs: `Authorization: Bearer <accessToken>`.
- Token refresh: use existing interceptor flow (`/auth/refresh`) on `401`.

### 1.2 Common request headers

| Header | Required | Notes |
|---|---|---|
| `Content-Type: application/json` | Yes | All documented endpoints use JSON payloads. |
| `Authorization: Bearer <token>` | Protected endpoints | Auth, Users (except register/login/etc.), Projects, Contributions. |
| `Accept-Language` | Optional | Recommended for future localization. |
| `X-Device-Name` | Optional | `deviceName` is currently in request body for auth endpoints. |

### 1.3 Error handling contract

Backend may return errors as:
- validation structure (`title`, `status`, `errors`)
- business error (`title`, `detail`)

UI recommendation:
- Form-level validation errors -> inline field errors.
- Business/server errors -> modal/snackbar (`AppFailureDialog` pattern).
- Silent failures for idempotent actions (e.g., resend) should still show user feedback.

### 1.4 State management recommendations

- Keep async states explicit: `initial`, `loading`, `success`, `error`, and optionally `empty`.
- Separate **form validation state** from **API state**.
- Prefer one cubit/bloc per screen flow:
  - Auth: existing blocs/cubits
  - Create project: `CreateProjectCubit`
  - Contribute/Borrow: `ContributeCubit`, `BorrowCubit`
  - Profile/Wallet: feature cubits
- Store tokens and user session centrally (already done via secure/shared storage).

---

## 2) Auth & Session Integration

Routes:
- `/login`, `/register`, `/verify`, `/forgot-password`, `/reset-password`, `/agreement`, `/dashboard`

### 2.1 API-to-screen mapping

| Endpoint | Purpose | Screen(s) | Trigger Timing |
|---|---|---|---|
| `POST /auth/register` | Create account | `RegisterScreen` | On submit |
| `POST /auth/verify-email` | Verify OTP | `VerifyScreen` | On verify submit |
| `POST /auth/resend-code` | Resend OTP | `VerifyScreen` | Resend CTA |
| `POST /auth/login` | Login with password | `LoginScreen` | On submit |
| `POST /auth/refresh` | Refresh access token | global network layer | Auto on `401` |
| `POST /auth/forgot-password` | Request reset code | `ForgotPasswordScreen` | On submit |
| `POST /auth/reset-password` | Reset password | `ResetPasswordScreen` | On submit |
| `POST /auth/google`, `POST /auth/apple` | External auth | social auth CTAs | On social CTA |
| `POST /auth/logout` | End session | profile/logout actions | On logout |
| `GET /users/me` | Bootstrap profile | Splash, Dashboard bootstrap | On app load/session restore |
| `GET /users/me/risk-disclaimer` | Fetch disclaimer | `AgreementScreen`, post-login gate | On login success + agreement load |
| `POST /users/me/risk-disclaimer` | Accept disclaimer | `AgreementScreen` | On continue |

### 2.2 Request/response mapping (critical)

#### Register (`/register`)
- Request fields from UI:
  - `fullName` <- full name text field
  - `email` <- email field
  - `password`, `confirmPassword` <- password fields
- Response:
  - `userId`, `requiresEmailVerification` -> navigate to `/verify` with email.

#### Verify (`/verify-email`)
- Request:
  - `email` <- route extra passed from register
  - `code` <- OTP field
- Response:
  - `tokens.accessToken`, `tokens.refreshToken` -> persist tokens
  - proceed to disclaimer check/gate.

#### Login (`/login`)
- Request:
  - `email`, `password`
  - `deviceName`, `ipAddress` (currently using constants)
- Response:
  - `tokens.*` -> persist
  - then call `GET /users/me/risk-disclaimer` to route:
    - `accepted=true` -> `/dashboard`
    - `accepted=false` -> `/agreement`

#### Forgot/Reset password
- Forgot response `message` -> success snackbar and move to reset screen.
- Reset request includes `email`, `code`, `newPassword`, `confirmNewPassword`.
- Reset success `message` -> return to login.

### 2.3 Validation rules

- Register/Login: email format + password strength on client before API call.
- Verify/Reset OTP: 6-digit code expected by backend.
- Backend remains source of truth for all server validation.

### 2.4 Loading, error, empty recommendations

- Disable CTA while loading.
- Show per-field errors when backend returns `errors`.
- Show dialog for `401/409/business` failures.
- Agreement empty guidelines -> fallback text + allow refresh.

### 2.5 Dependencies

- `login/register/verify/social` -> token persistence -> `GET /users/me/risk-disclaimer` -> route decision.
- `GET /users/me` drives profile/wallet headers and dashboard personalization.

---

## 3) Dashboard, Home, Discover, Notifications

Routes:
- `/dashboard`, `/notifications`

### 3.1 API mapping

| Endpoint | Screen(s) | Data used by UI | Trigger |
|---|---|---|---|
| `GET /users/me` | Dashboard shell/profile summary | name, avatar, roles | On dashboard init + pull-to-refresh |
| `GET /projects?scope=mine` | Home tab | project cards for own/joined context | On tab load + refresh |
| `GET /projects?scope=discover` | Discover tab | discover list/cards | On tab load + pagination/refresh |
| (future notifications endpoint) | Notifications screen | feed list, unread markers | On screen load + refresh |

### 3.2 UI mapping details

- Card fields from list response:
  - `id`, `name`, `description`, `type`, `state`, `targetAmount`, `endsAtUtc`, `borrowingEnabled`.
- Route decision for detail screen:
  - investment type -> `/project/investment-detail`
  - other supported runtime types -> `/project/detail`

### 3.3 Empty/error recommendations

- Empty home/discover -> friendly "no projects yet" with CTA.
- Pagination errors -> inline retry row; keep loaded items visible.
- Hard failure on initial load -> full-page retry state.

---

## 4) Project Detail Family (User + Leader)

Routes:
- `/project/detail`, `/project/investment-detail`
- plus related actions routes (`/project/join-requests`, `/project/create-announcement`, etc.)

### 4.1 Core detail API mapping

| Endpoint | Purpose | Screen | Timing |
|---|---|---|---|
| `GET /projects/{id}` | Full detail aggregate | Project detail screens | On load + manual refresh |
| `PUT /projects/{id}` | Edit project data | Create project edit mode | On submit |
| `POST /projects/{id}/launch` | Launch draft | Leader action | On confirm |
| `POST /projects/{id}/cancel` | Cancel project | Cancel flow | On confirm |
| `POST /projects/{id}/complete` | Mark complete | Mark successful flow | On confirm/finalization |

### 4.2 Response-to-UI mapping (`GET /projects/{id}`)

- `project.*` -> header, name, description, type chips, deadlines, funding stats.
- `rules.*` -> contribution rules, ROI, repayment/penalty details.
- `viewerMembership.*` -> role-based UI decisions (leader/member actions).
- `members[]` -> member list and member cards.
- `invites[]` -> invite management display.

### 4.3 Role-based action dependencies

- Leader-only actions enabled when `viewerMembership.role` is `Leader`/`CoLeader`.
- Member-only CTA availability based on membership `status` and project `state`.

### 4.4 Edge cases

- `404` on detail -> navigate back with "Project not found".
- State transition errors (`400`) -> keep current screen, show reason from `detail`.
- Role mismatch (`403`) -> remove action controls and show permission warning.

---

## 5) Membership, Invites, Join Requests, Member Management

### 5.1 API mapping

| Endpoint | Screen/Flow | Trigger | Notes |
|---|---|---|---|
| `POST /projects/join` | Invite join flow | Submit invite code | Returns pending/approved membership state |
| `POST /projects/{id}/invites` | Leader invite dialog | Create invite | Store and refresh invite list |
| `GET /projects/invites/{inviteCode}/preview` | Invite preview screen/dialog | On code input/scan | Validate joinability before submit |
| `POST /projects/{id}/memberships/{membershipId}/approve` | Join requests | Approve CTA | 204 on success |
| `POST /projects/{id}/memberships/{membershipId}/reject` | Join requests | Reject CTA | 204 on success |
| `POST /projects/{id}/members/{userId}/co-leader` | Member detail | Assign action | 204 |
| `DELETE /projects/{id}/members/{userId}/co-leader` | Member detail | Revoke action | 204 |
| `DELETE /projects/{id}/members/{userId}` | Member management | Remove member | 204 |
| `PATCH /projects/{id}/members/{userId}/borrow-limit` | Member detail/limit control | Save limit | 204 |
| `POST /projects/{id}/members/{userId}/defaulted` | Penalty/member action | Mark defaulted | 204 |
| `POST /projects/{id}/members/{userId}/remove-non-repayment` | Penalty/member action | Remove non-repayment | 204 |

### 5.2 Integration behavior

- For 204 responses, optimistically update list or refetch detail/members.
- All moderation actions should require confirm dialogs.
- Use idempotent UI: disable action buttons while request in progress.

---

## 6) Contribute Flow Integration

Route: `/project/contribute`

### 6.1 API sequence

| Step | Endpoint | Trigger | UI Consumption |
|---|---|---|---|
| Load config | `GET /contributions/projects/{projectId}/config` | Screen load | min amount, fee rate, wallets, non-refundable flag |
| Preview | `POST /contributions/preview` | On amount/payment/ack change or next step | fee, balance after, pot after |
| Confirm | `POST /contributions/confirm` | Final submit | success IDs, post-balance, success message |

Related:
- `GET /contributions/wallets/{walletId}/balance` -> refresh wallet pill
- `GET /contributions/projects/{projectId}/pot-balance` -> post-success summary (optional)

### 6.2 Request mapping

- `projectId` <- route args/project context
- `membershipId` <- viewer membership from project detail
- `walletId` <- selected wallet/pill
- `amount` <- stacked currency field
- `currency` <- selected/project currency
- `externalReference` <- payment provider reference (nullable)
- `confirmNonRefundable` <- acceptance switch

### 6.3 Validation and states

- Validate amount >= `minimumContributionAmount`.
- Enforce `confirmNonRefundable=true` when required.
- If wallet insufficient (`400` detail), show inline amount error + keep entered data.

### 6.4 Empty/error/loading

- No wallets in config -> empty state with CTA to add funding method.
- Preview failure should not block amount editing.
- Confirm failure should preserve form and selected wallet.

---

## 7) Borrow Flow Integration

Route: `/project/borrow`

### 7.1 API mapping

| Endpoint | Purpose | Timing |
|---|---|---|
| `POST /projects/{id}/borrow-requests` | Create borrow request | On final submit |
| `GET /projects/{id}` | Borrow limits/rules source (if not already loaded) | On entry/refresh |

### 7.2 Request mapping

- `requestedAmount` <- amount field
- `reason` <- note field

Validation:
- amount > 0
- amount <= member borrow limit (if available from detail/rules)
- reason required if business rule requires it

### 7.3 Error handling

- `400` invalid business rule -> inline + dialog.
- `403` unauthorized/member state invalid -> disable submit and show reason.

---

## 8) Borrow Requests List (User + Leader Modes)

Route: `/project/borrow-requests`

### 8.1 API mapping

| Endpoint | Leader Mode | User Mode | Trigger |
|---|---|---|---|
| `GET /projects/{id}` (or dedicated list API if added) | Full moderation context | Own/member context | On screen load |
| `PATCH/POST decision endpoint` (implementation route as per backend pattern) | approve/reject request | N/A | On leader decision |

> If backend exposes borrow request list under project detail aggregate only, map from `GET /projects/{id}`. If a dedicated endpoint is added later, switch list loading to that API but keep same view model.

---

## 9) Create Project Wizard + Edit Project

Routes:
- `/create-project/amount`
- `/create-project/details`
- `/create-project/borrowing`
- `/create-project/review`
- `/create-project/success`

### 9.1 API mapping

| Endpoint | Mode | Trigger | Used by |
|---|---|---|---|
| `POST /projects` | Create | Final review submit | All wizard fields |
| `GET /projects/{id}` | Edit prefill | Edit flow load | populate form |
| `PUT /projects/{id}` | Edit save | Review submit in edit mode | changed fields only |
| `POST /projects/{id}/launch` | Optional post-create launch | Leader action | state transition |

### 9.2 Request field mapping (wizard -> API)

- Basics: `name`, `description`, `type`, `visibility`
- Amount/deadline: `targetAmount`, `maxMembers`, `endsAtUtc`, `contributionDeadlineUtc`
- Borrowing rules: `borrowingEnabled`, `roiPercentage`, `repaymentWindowDays`, `repaymentGraceDays`, `penaltyPercentage`, `minimumContributionAmount`, `joinApprovalRequired`, `contributionsAreNonRefundable`
- UX helper values: `suggestedContributionAmount`

### 9.3 Validation guidance

- numeric fields > 0 as required
- date ordering: contribution deadline <= project end
- guard edit restrictions returned by backend (e.g., target change on active project)

---

## 10) Success, Cancellation, Voting, Finance Actions (Leader)

### 10.1 API mapping

| Endpoint | Screen/Action | Timing |
|---|---|---|
| `POST /projects/{id}/goal/resolve` | Mark successful flow | submit |
| `POST /projects/{id}/deadline/extend` | leader actions | submit |
| `POST /projects/{id}/closure-voting/open` | start vote | submit |
| `POST /projects/{id}/closure-voting/vote` | user/leader vote actions | submit |
| `POST /projects/{id}/closure-voting/extend` | voting admin | submit |
| `POST /projects/{id}/closure-voting/finalize` | finalize vote | submit |
| `POST /projects/{id}/investment/external` | investment recording UI | submit |
| `POST /projects/{id}/complete` | complete project | final step |

### 10.2 Integration recommendations

- Keep action history in local state so user sees immediate status updates.
- For voting actions, poll status or refetch detail after vote open/cast/finalize.
- Use explicit confirmation modals for irreversible operations.

---

## 11) Wallet, Profile, and Transaction History

Current week-4 backend doc fully defines contributions and user profile endpoints, but wallet card management endpoints are not explicitly listed there. Integrate as follows:

### 11.1 Profile APIs (confirmed)

| Endpoint | Screen | Fields Used |
|---|---|---|
| `GET /users/me` | Profile, dashboard shell | name, email, username, photo, roles |
| `PUT /users/me` | Edit profile | firstName, lastName, userName, photoUrl |

### 11.2 Transaction/proof APIs (available)

| Endpoint | Screen | Trigger |
|---|---|---|
| `GET /contributions?projectId={projectId}` | project contribution history widgets | on load/refresh |
| `GET /contributions/{id}` | contribution detail sheet/screen | on tap |

### 11.3 Ledger endpoint note

- `POST /ledger/transactions` exists but is typically backend/internal.
- Do not call from mobile unless explicitly approved for direct client usage.

---

## 12) API Timing Matrix

| When | Calls |
|---|---|
| App bootstrap | `GET /users/me` (if token exists), optionally disclaimer status |
| Login submit | `POST /auth/login` -> `GET /users/me/risk-disclaimer` |
| Register submit | `POST /auth/register` |
| Verify submit | `POST /auth/verify-email` |
| Dashboard tab open | project lists by scope |
| Project detail open | `GET /projects/{id}` |
| Contribute open | contribution config |
| Contribute amount/selection change | contribution preview |
| Contribute confirm | contribution confirm |
| Borrow confirm | create borrow request |
| Pull-to-refresh | repeat current screen primary query |
| 401 from protected API | auto refresh token, then retry |

---

## 13) Navigation + Integration Dependencies

1. Auth token is prerequisite for all protected routes.
2. Disclaimer acceptance gates entry to `/dashboard`.
3. Project card payload must carry enough data for route decision (investment vs generic detail).
4. Detail APIs feed downstream flows:
   - contribute (project/membership context)
   - borrow (limits/rules)
   - member management actions.
5. Successful mutations should update upstream lists (via optimistic update or refetch strategy).

---

## 14) Edge Cases & Fallback Handling

- Token expired + refresh fails -> clear session and route to `/login`.
- Project deleted while viewing -> show not found and pop route.
- Invite expired -> show invite invalid state with retry/new code CTA.
- Contribution confirm conflict (`409`) -> ask user to retry with fresh reference.
- No internet -> offline error UI with retry; keep unsent form values intact.
- Slow network -> skeleton loaders for lists, spinner for submit actions only.
- Empty list states:
  - no projects
  - no borrow requests
  - no contributions
  - no members pending approval

---

## 15) Suggested Implementation Order (Practical)

1. Auth + disclaimer + session restore
2. Dashboard lists (`scope=mine`, `scope=discover`)
3. Project detail aggregate (`GET /projects/{id}`)
4. Contribute flow (`config` -> `preview` -> `confirm`)
5. Borrow submit + borrow moderation actions
6. Membership/invite/join requests
7. Create/edit project wizard
8. Success/cancel/voting actions
9. Profile update and contribution history polish

---

## 16) QA Checklist (Per Screen Integration)

- Request payload exactly matches backend contract.
- Required auth header attached for protected API.
- Client validation + backend validation both handled.
- Loading state blocks duplicate submit.
- Error paths display user-friendly message.
- Empty state has useful CTA.
- Navigation after success is deterministic.
- Local state refresh strategy is defined (optimistic vs refetch).

