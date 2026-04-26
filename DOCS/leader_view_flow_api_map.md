# Leader View Flow + API Map

This document maps the **leader-side** screens and route connections, then lists the API contracts you will need to wire for project administration.

## 1) Leader entry points

Leader typically enters from:

- `/dashboard` -> Home tab (`HomeScreen`) -> "My Projects"
- card tap -> detail open via `openProjectFromCard(...)` with `isLeaderView: true`
- detail route:
  - `/project/detail` (`ProjectDetailScreen`) or
  - `/project/investment-detail` (`InvestmentProjectDetailScreen`)
  - both require `extra: ProjectDetailRouteArgs(project)`

---

## 2) Create Project wizard (leader owned)

Routes:

1. `/create-project/amount`
2. `/create-project/details`
3. `/create-project/borrowing`
4. `/create-project/review`
5. `/create-project/success`

Also reachable from leader action "Edit project":

- from detail menu -> `/create-project/details` with `extra: true` (edit mode)
- then `/create-project/borrowing` with `extra: true`

### API to integrate
- `POST /projects` (create)
- `GET /projects/{projectId}` (prefill edit)
- `PATCH /projects/{projectId}` (edit details/borrowing rules)
- `POST /projects/{projectId}/publish` (if separate from create)

---

## 3) Leader project detail menu actions

In detail header (`LeaderActionMenu`) the leader can open:

- Join requests -> `/project/join-requests`
- Add announcement -> `/project/create-announcement`
- Edit project -> `/create-project/details` (`extra: true`)
- Invite members -> modal dialog (`AppInviteMembersDialog`)
- Mark successful -> `/project/mark-successful` with `MarkSuccessfulRouteArgs`
- Cancel project -> `/project/cancel` with `CancelProjectRouteArgs`

### API to integrate
- `GET /projects/{projectId}/join-requests`
- `PATCH /projects/{projectId}/join-requests/{requestId}` (approve/reject)
- `POST /projects/{projectId}/announcements`
- `DELETE /projects/{projectId}/announcements/{announcementId}`
- `POST /projects/{projectId}/invites`
- `POST /projects/{projectId}/mark-successful/vote-start`
- `POST /projects/{projectId}/cancel`

---

## 4) Borrow request moderation (leader)

Screen route:
- `/project/borrow-requests` with
  - `extra: BorrowRequestsRouteArgs(requests, isLeaderMode: true)`

Leader actions:
- approve / reject borrow request
- inspect request details

### API to integrate
- `GET /projects/{projectId}/borrow-requests`
- `PATCH /projects/{projectId}/borrow-requests/{requestId}` with decision

---

## 5) Member management (leader)

From detail tabs:
- manage members panel
- member tap -> `/project/member-detail` with `MemberDetailRouteArgs(..., isLeaderView: true)`
- optional penalty route -> `/project/member-penalty-action` with `extra: MemberEntity`

### API to integrate
- `GET /projects/{projectId}/members`
- `GET /projects/{projectId}/members/{memberId}`
- `POST /projects/{projectId}/members/{memberId}/penalties`
- `PATCH /projects/{projectId}/members/{memberId}` (status, permissions, etc.)

---

## 6) Mark project successful flow (leader initiated)

Route:
- `/project/mark-successful` with `MarkSuccessfulRouteArgs(memberCount)`

Leader starts vote, then members vote via their own flow.

### API to integrate
- `POST /projects/{projectId}/success-vote/start`
- `GET /projects/{projectId}/success-vote`
- `POST /projects/{projectId}/success-vote/close` (optional)
- `POST /projects/{projectId}/success-vote/force-result` (admin optional)

---

## 7) Cancel project flow (leader initiated)

Routes:
- `/project/cancel` with `CancelProjectRouteArgs`
- `/project/cancelled` with `ProjectCancelledRouteArgs`

### API to integrate
- `POST /projects/{projectId}/cancel` (with reason and settlement options)
- `GET /projects/{projectId}/settlement-preview`
- `POST /projects/{projectId}/settlement/execute`

---

## 8) Data payloads used by leader routes

Keep these route extras stable:

- `ProjectDetailRouteArgs`
- `BorrowRequestsRouteArgs`
- `MemberDetailRouteArgs`
- `MarkSuccessfulRouteArgs`
- `CancelProjectRouteArgs`
- `ProjectCancelledRouteArgs`

If API models evolve, adapt these DTO-like route args in one pass to avoid broken navigation.

---

## 9) Leader-side API integration order

1. Create/Edit project endpoints
2. Project detail + members + borrow request feeds
3. Join request moderation
4. Announcement CRUD + invite members
5. Borrow moderation decisions
6. Mark-successful vote lifecycle
7. Project cancellation + settlement

---

## 10) Practical implementation note

The UI currently uses mock/domain entities in several places. For smooth backend integration:

- create repositories per feature (project detail, moderation, announcements)
- map API DTO -> existing entities (`ProjectDetailEntity`, `MemberEntity`, `BorrowRequestEntity`)
- keep route args lightweight (IDs + display labels), fetch full data inside each screen cubit/bloc where possible.

