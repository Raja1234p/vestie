# Vestie Post-Auth Flow API Integration (Detailed)

This document covers **everything after authentication** and explains API integration in a screen-first way:

- each screen and when it loads
- each important UI field and which API field it maps to
- User vs Leader behavior differences
- submit/refresh/error expectations

Use this with:

- `DOCS/api_integration_week4_screen_mapping.md`
- `DOCS/user_leader_flow_all_screens.md`

---

## 1) Scope and Assumptions

- Auth is already completed (login/register/verify/disclaimer gate).
- User has valid token and has entered `/dashboard`.
- Architecture remains:
  - UI -> Cubit/Bloc -> UseCase -> Repository -> RemoteDataSource.

---

## 2) Dashboard Shell + Tabs (Post-Auth Entry)

### 2.1 Dashboard shell

**Route**: `/dashboard`  
**Primary API**: `GET /users/me`

#### UI fields -> API fields

- Header name -> `firstName`, `lastName`, fallback to `userName`
- Avatar/initials -> `photoUrl` (or derived initials)
- Role display / permissions -> `roles[]`

#### Behavior

- **User view**: sees personal summary, user actions.
- **Leader view**: same shell, but project cards may expose leader menus in detail screens.

#### Integration notes

- Fetch on dashboard init and pull-to-refresh.
- On 401/refresh-fail: clear session and route to `/login`.

---

## 3) Home + Discover Project Lists

### 3.1 Home list (mine)

**Route context**: dashboard home tab  
**API**: `GET /projects?scope=mine`

### 3.2 Discover list

**Route**: discover tab  
**API**: `GET /projects?scope=discover`

#### Card field mapping

- Project id -> `id`
- Title -> `name`
- Subtitle/description -> `description`
- Type chip -> `type`
- State badge -> `state`
- Goal/target -> `targetAmount`
- Deadline label -> `endsAtUtc`
- Borrow availability -> `borrowingEnabled`

#### Navigation behavior

- Investment project -> `/project/investment-detail`
- Other project types -> `/project/detail`
- Route extra must include `projectId`.

#### User vs Leader

- **User**: opens detail and member actions only.
- **Leader**: same list API, but detail screen later enables leader menus based on membership role from detail response.

---

## 4) Project Detail (Core Aggregate)

### 4.1 Generic + Investment detail

**Routes**:

- `/project/detail`
- `/project/investment-detail`

**Primary API**: `GET /projects/{id}`

#### Section mapping

- Header/title -> `project.name`
- State/type/meta -> `project.type`, `project.state`, `project.endsAtUtc`
- Funding stats -> `project.targetAmount` (+ mapped current amount if available)
- Rules block -> `rules.*`
- Member list -> `members[]`
- Viewer context -> `viewerMembership.*` (critical for role behavior)

#### ViewerMembership mapping used by flows

- Membership id for contribute/borrow -> `viewerMembership.membershipId`
- Borrow limit -> `viewerMembership.borrowLimitAmount`
- Leader permissions -> `viewerMembership.role` (`Leader`/`CoLeader`)

#### User vs Leader behavior

- **User view**
  - Can contribute/borrow if allowed by project state/rules.
  - Sees member list and own interaction actions.
- **Leader view**
  - Sees leader action menu:
    - Join Requests
    - Invite Members
    - Mark Successful
    - Cancel Project
    - (Edit project where enabled)

---

## 5) Contribute Flow (User + Leader as member)

### 5.1 Flow route

**Route**: `/project/contribute`

### 5.2 API sequence

1. `GET /contributions/projects/{projectId}/config` (on load)
2. `POST /contributions/preview` (before final step)
3. `POST /contributions/confirm` (final submit)
4. Optional reads:
   - `GET /contributions/wallets/{walletId}/balance`
   - `GET /contributions/projects/{projectId}/pot-balance`

#### UI field -> request field mapping

- Selected project -> `projectId`
- Current membership -> `membershipId`
- Selected funding wallet -> `walletId`
- Amount input -> `amount`
- Currency -> `currency`
- External payment ref (if provided) -> `externalReference`
- Non-refundable switch -> `confirmNonRefundable`

#### Config response -> UI mapping

- Min contribution validation -> `minimumContributionAmount`
- Fee info -> fee rate/amount fields from config/preview
- Wallet options -> `wallets[]`
- Non-refundable enforcement -> `contributionsAreNonRefundable`

#### User vs Leader

- Same API behavior for any member contributing.
- Leader has no special endpoint in this flow.

---

## 6) Borrow Flow (Request Creation)

### 6.1 Flow route

**Route**: `/project/borrow`

**APIs**:

- `POST /projects/{id}/borrow-requests` (submit)
- `GET /projects/{id}` (limits/rules source)

#### UI field mapping

- Amount -> `requestedAmount`
- Reason/note -> `reason`

#### Validation expectations

- amount > 0
- amount <= member limit from detail/rules
- required reason if backend policy enforces it

#### User vs Leader

- **User**: creates borrow request.
- **Leader**: can also request if member of project, but moderation is separate flow.

---

## 7) Join Requests (Leader Moderation)

### 7.1 Screen

**Route**: `/project/join-requests`  
**APIs**:

- Source list via `GET /projects/{id}` -> pending `members[]`
- Approve: `POST /projects/{id}/memberships/{membershipId}/approve`
- Reject: `POST /projects/{id}/memberships/{membershipId}/reject`

#### Card field mapping

- Person identity -> member `firstName/lastName/userName`
- Membership status -> `status` == pending
- Membership id for actions -> `membershipId`

#### Behavior

- Approve/reject buttons disabled while request in-flight.
- On success (204): refetch detail/list or optimistically remove row.

#### User vs Leader

- **Leader only screen/action**.
- **User** does not see moderation controls.

---

## 8) Invite + Join by Code

### 8.1 Leader invite generation

**Entry**: leader action menu -> Invite Members  
**API**: `POST /projects/{id}/invites`

#### Request fields

- `requiresApproval`
- `expiresInDays`
- `maxUses`

#### Response mapping

- `inviteCode` (or full link/code payload) -> invite dialog content/copy/share.

### 8.2 Join invite (member side)

**APIs**:

- Preview: `GET /projects/invites/{inviteCode}/preview`
- Join submit: `POST /projects/join`

#### Mapping

- Code input/scan -> `inviteCode`
- Preview payload -> project name, joinability, expiration, approval requirement
- Join response -> membership state (pending/approved)

---

## 9) Member Management (Leader in Member Detail)

### 9.1 Member detail actions

**Entry**: project detail -> member row  
**APIs**:

- Make co-leader: `POST /projects/{id}/members/{userId}/co-leader`
- Remove co-leader: `DELETE /projects/{id}/members/{userId}/co-leader`
- Remove member: `DELETE /projects/{id}/members/{userId}`
- Mark defaulted: `POST /projects/{id}/members/{userId}/defaulted`
- Remove non-repayment: `POST /projects/{id}/members/{userId}/remove-non-repayment`
- (Optional borrow-limit admin): `PATCH /projects/{id}/members/{userId}/borrow-limit`

#### Required route context

- `projectId`
- target member `userId`

#### User vs Leader

- **Leader**: sees action buttons and confirm dialogs.
- **User**: read-only member profile style; no moderation controls.

---

## 10) Success / Cancellation / Voting Actions (Leader + Members)

### 10.1 Leader success actions

**Route**: `/project/mark-successful`  
**APIs**:

- Start vote: `POST /projects/{id}/closure-voting/open`
- Resolve goal: `POST /projects/{id}/goal/resolve`
- Finalize vote: `POST /projects/{id}/closure-voting/finalize`
- Complete project: `POST /projects/{id}/complete`
- Extend vote window (if exposed by UI): `POST /projects/{id}/closure-voting/extend`

### 10.2 Member vote screen

**Route**: `/user/success-vote`  
**API**: `POST /projects/{id}/closure-voting/vote`

#### Vote mapping

- Yes/No CTA -> `voteForSuccess: true/false`
- Requires `projectId` in route args for real API submit.

### 10.3 Cancel project flow

**Route**: `/project/cancel`  
**API**: `POST /projects/{id}/cancel`

#### UX expectation

- Keep existing confirm dialog sequence.
- On success route to cancelled/success status screen.

---

## 11) Create/Edit Project Wizard (Post-Auth Leader Flow)

### 11.1 Routes

- `/create-project/amount`
- `/create-project/details`
- `/create-project/borrowing`
- `/create-project/review`
- `/create-project/success`

### 11.2 APIs

- Create: `POST /projects`
- Edit prefill: `GET /projects/{id}`
- Edit save: `PUT /projects/{id}`
- Launch: `POST /projects/{id}/launch`

#### Wizard field -> API field mapping

- Name -> `name`
- Description -> `description`
- Type -> `type`
- Visibility -> `visibility`
- Target -> `targetAmount`
- Max members -> `maxMembers`
- End date -> `endsAtUtc`
- Contribution deadline -> `contributionDeadlineUtc`
- Borrowing enabled -> `borrowingEnabled`
- ROI -> `roiPercentage`
- Repayment window -> `repaymentWindowDays`
- Grace period -> `repaymentGraceDays`
- Penalty percent -> `penaltyPercentage`
- Minimum contribution -> `minimumContributionAmount`
- Join approval switch -> `joinApprovalRequired`
- Non-refundable switch -> `contributionsAreNonRefundable`
- Suggested contribution -> `suggestedContributionAmount`

#### User vs Leader

- **Leader** uses create/edit/launch.
- **User** generally has no access to project creation actions.

---

## 12) Profile + Post-Auth Account Maintenance

### 12.1 Profile screens

**APIs**:

- `GET /users/me`
- `PUT /users/me`

#### Edit field mapping

- First name -> `firstName`
- Last name -> `lastName`
- Username -> `userName`
- Profile image -> `photoUrl`

#### User vs Leader

- Same endpoints and form mapping.
- Role affects what app areas are visible, not profile payload shape.

---

## 13) Error and Loading Rules (Apply to Every Post-Auth Screen)

- Disable submit CTAs while request is in-flight.
- Preserve form values on error (do not clear user input).
- Show backend `detail/message` in snackbar/dialog.
- For 204 mutation responses, update UI via refetch or optimistic remove/update.
- For initial load failures, show retry-capable state.

---

## 14) Quick Endpoint Checklist (Post-Auth)

- [x] `GET /users/me`
- [x] `GET /projects?scope=mine`
- [x] `GET /projects?scope=discover`
- [x] `GET /projects/{id}`
- [x] `POST /projects`
- [x] `PUT /projects/{id}`
- [x] `POST /projects/{id}/launch`
- [x] `POST /projects/{id}/cancel`
- [x] `POST /projects/{id}/borrow-requests`
- [x] `GET /contributions/projects/{projectId}/config`
- [x] `POST /contributions/preview`
- [x] `POST /contributions/confirm`
- [x] `GET /contributions?projectId={projectId}`
- [x] `GET /contributions/{id}`
- [x] `GET /contributions/projects/{projectId}/pot-balance`
- [x] `GET /contributions/wallets/{walletId}/balance`
- [x] `POST /projects/{id}/invites`
- [x] `GET /projects/invites/{inviteCode}/preview`
- [x] `POST /projects/join`
- [x] `POST /projects/{id}/memberships/{membershipId}/approve`
- [x] `POST /projects/{id}/memberships/{membershipId}/reject`
- [x] `POST /projects/{id}/members/{userId}/co-leader`
- [x] `DELETE /projects/{id}/members/{userId}/co-leader`
- [x] `DELETE /projects/{id}/members/{userId}`
- [x] `POST /projects/{id}/members/{userId}/defaulted`
- [x] `POST /projects/{id}/members/{userId}/remove-non-repayment`
- [x] `POST /projects/{id}/closure-voting/open`
- [x] `POST /projects/{id}/closure-voting/vote`
- [x] `POST /projects/{id}/closure-voting/extend`
- [x] `POST /projects/{id}/closure-voting/finalize`
- [x] `POST /projects/{id}/goal/resolve`
- [x] `POST /projects/{id}/deadline/extend`
- [x] `POST /projects/{id}/complete`
- [x] `PUT /users/me`

---

## 15) Final Guidance

When implementing future changes, keep this rule:

**Do not change existing UX flow unless explicitly requested.**  
Only swap data source from static/mock to API and preserve:

- same screen order
- same button positions/labels
- same dialogs
- same success/failure navigation patterns

