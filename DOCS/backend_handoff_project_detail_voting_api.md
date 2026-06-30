# Backend handoff — Project detail voting API (`GET /projects/{id}`)

**Audience:** Vestie backend team  
**From:** Mobile (Flutter) — Week 11 closure / success voting UI  
**Date:** 2026-06-02  
**Status:** Backend implemented — mobile locked to contract (2026-06-02)

---

## 1. Purpose

The mobile app drives **all voting UI** (member cast, member post-vote, co-leader cast, leader monitor “View Success Votes”) from **`GET /projects/{id}`** when Week 11 fields are present.

We want **one detail response** to carry vote state so the app does **not** need extra calls to `GET …/closure-voting/active` for normal flows.

**Separate write APIs stay as-is** (open / vote / finalize). After any vote POST, the app reloads **`GET /projects/{id}`** and expects the updated `voting` object below.

---

## 2. APIs — what to update vs what stays

### 2.1 Primary — **MUST UPDATE** (this handoff)

| Method | URL | Change |
|--------|-----|--------|
| `GET` | `/api/v1/projects/{projectId}` | Extend existing `voting` object with **`memberVotes[]`**; ensure **`hasVoted`** is **per viewer**; keep counts in sync |

**Full URL example (staging):**

```
GET https://vestie-backend-byexejcphyhaapfy.centralus-01.azurewebsites.net/api/v1/projects/{projectId}?membersPage=1&membersPageSize=50&announcementsPage=1&announcementsPageSize=20&invitesPage=1&invitesPageSize=20
```

**Headers:** `Authorization: Bearer <token>`, `Accept: application/json`

**Response content-type:** `application/json`

---

### 2.2 Write APIs — **no response shape change required** for this handoff

Mobile already calls these; they are **out of scope** for this document except that **`GET /projects/{id}` must reflect their effects** after reload.

| Method | URL | Purpose |
|--------|-----|---------|
| `POST` | `/api/v1/projects/{projectId}/closure-voting/open` | Leader / co-leader starts vote window |
| `POST` | `/api/v1/projects/{projectId}/closure-voting/vote` | Member / co-leader casts agree or disagree |
| `POST` | `/api/v1/projects/{projectId}/closure-voting/finalize` | Leader finalizes after deadline |

**Staging examples:**

```
POST https://vestie-backend-byexejcphyhaapfy.centralus-01.azurewebsites.net/api/v1/projects/{projectId}/closure-voting/open
POST https://vestie-backend-byexejcphyhaapfy.centralus-01.azurewebsites.net/api/v1/projects/{projectId}/closure-voting/vote
POST https://vestie-backend-byexejcphyhaapfy.centralus-01.azurewebsites.net/api/v1/projects/{projectId}/closure-voting/finalize
```

**Vote POST body (existing):**

```json
{ "vote": "Yes" }
```

or

```json
{ "vote": "No" }
```

---

### 2.3 Secondary — **optional alignment** (legacy fallback only)

| Method | URL | Mobile usage today |
|--------|-----|-------------------|
| `GET` | `/api/v1/projects/{projectId}/closure-voting/active` | Used **only** when `GET /projects/{id}` has **no** Week 11 `voting` envelope (legacy projects). **Not required** if detail always returns `voting` when a vote is open. |

If you keep this endpoint, tallies (`thumbsUp`, `thumbsDown`, `notYetVoted`) should match `voting.agreedCount`, `voting.disagreedCount`, `voting.pendingCount` on detail.

---

### 2.4 Not part of voting handoff

These are loaded on **project detail screen** for other features (wallet, borrow tab, join requests). **Do not** add voting fields to them.

| Method | URL |
|--------|-----|
| `GET` | `/api/v1/projects/{projectId}/pot` |
| `GET` | `/api/v1/projects/{projectId}/borrow-requests` |
| `GET` | `/api/v1/projects/{projectId}/memberships/pending` |

---

## 3. Top-level Week 11 fields on `GET /projects/{id}`

Already partially implemented. **Keep and ensure consistent.**

| Field | Type | Values | When present |
|-------|------|--------|--------------|
| `projectStatus` | string | `ongoing`, `completed`, `cancelled` | Always (Week 11 envelope) |
| `votingStatus` | string | `not_started`, `pending`, `done` | Always (Week 11 envelope) |
| `userRole` | string | `leader`, `co_leader`, `member` | Always — **caller's role on this project** |
| `canStopContributions` | boolean | | Investment projects — stop-contributions vote flow |
| `voting` | object | See §4 | When `votingStatus` is `pending` or `done` |

**`userRole` vs `viewerMembership.role`:** Mobile prefers top-level `userRole` for Week 11 gates. Keep both aligned.

---

## 4. `voting` object — full schema

### 4.1 Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `startedAtUtc` | string (ISO-8601 UTC) | Yes | Vote window start |
| `deadlineAtUtc` | string (ISO-8601 UTC) | Yes | Vote window end |
| `agreedCount` | int | Yes | Members who voted **agree** |
| `disagreedCount` | int | Yes | Members who voted **disagree** |
| `pendingCount` | int | Yes | Members who have **not** voted yet |
| `hasVoted` | boolean | Yes | **`true` if the current API caller has cast a vote** |
| `isFinalized` | boolean | Yes | `true` after leader finalizes |
| `memberVotes` | array | **Yes when vote open or done** | Per-member rows — **NEW / required for correct UI** |

### 4.2 Optional (nice to have — mobile does not require today)

| Field | Type | Description |
|-------|------|-------------|
| `closureVoteId` | string | Same id as `GET …/closure-voting/active` |
| `voteType` | string | `SuccessVote`, `StopContributionsVote`, `FinalClosureVote` |
| `eligibleVoterCount` | int | Voters excluding group leader (vacation success vote) |

---

## 5. `voting.memberVotes[]` row schema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `membershipId` | string | Yes | Match `viewerMembership.membershipId` for current user |
| `userId` | string | Yes | User id |
| `voteStatus` | string | Yes | `agreed`, `disagreed`, or `waiting` |
| `displayName` | string | Recommended | Shown in leader “Member Votes” list |
| `firstName` | string | Optional | Fallback for display name |
| `lastName` | string | Optional | Fallback for display name |
| `userName` | string | Optional | Fallback for display name |

**Alias accepted by mobile:** `vote` instead of `voteStatus` (prefer `voteStatus`).

### 5.1 `voteStatus` enum

| Value | UI label |
|-------|----------|
| `agreed` | Agreed |
| `disagreed` | Disagreed |
| `waiting` | Waiting |

---

## 6. Business rules

### 6.1 Who appears in `memberVotes[]`

| Project type | Vote type | Who is in `memberVotes[]` |
|--------------|-----------|---------------------------|
| Vacation / Emergency | Success vote | **Members + co-leaders** who must vote. **Exclude group leader** (leader monitors only). |
| Investment | Stop contributions | Per product rules (typically members + co-leader). |
| Investment | Final closure | Per product rules. |

For the sample project below (vacation, 1 member + 1 leader): **`memberVotes` has exactly 1 row** (the member Maha).

### 6.2 Count consistency (strict)

```
agreedCount     = count(memberVotes where voteStatus == "agreed")
disagreedCount  = count(memberVotes where voteStatus == "disagreed")
pendingCount    = count(memberVotes where voteStatus == "waiting")

agreedCount + disagreedCount + pendingCount == memberVotes.length
```

### 6.3 `hasVoted` (viewer-specific)

| Viewer | Success vote (vacation) | Expected `hasVoted` |
|--------|-------------------------|---------------------|
| Group leader | Does not cast | `false` |
| Member / co-leader, not voted | | `false` |
| Member / co-leader, voted | | `true` |

After a member votes, their row in `memberVotes` must be `agreed` or `disagreed` (not `waiting`).

### 6.4 `votingStatus` transitions

| State | Meaning |
|-------|---------|
| `not_started` | No open vote; `voting` may be omitted or null |
| `pending` | Vote window open; `voting` required |
| `done` | Deadline passed, not finalized; leader may finalize |

### 6.5 Summary card amounts (no new fields)

Mobile reads from existing `project` object:

| UI | Source |
|----|--------|
| Goal | `project.targetAmount` |
| Raised | `project.raisedAmount` or `project.potAmount` |
| Member count (fallback) | `members.items.length` or `memberVotes.length` |

---

## 7. Complete response examples

Base project id used in examples: `eb3e9b1a-0cd1-4355-9547-751648ec5962`

---

### 7.1 Leader — vote open, nobody has voted

**Request:** `GET /api/v1/projects/eb3e9b1a-0cd1-4355-9547-751648ec5962?...`  
**Caller:** Group leader (`userRole: "leader"`)

```json
{
  "project": {
    "id": "eb3e9b1a-0cd1-4355-9547-751648ec5962",
    "name": "ggg",
    "description": "hhh",
    "type": "vacation",
    "visibility": "public",
    "state": "active",
    "targetAmount": 500.0,
    "endsAtUtc": null,
    "launchedAtUtc": "2026-06-30T15:37:56+00:00",
    "borrowingEnabled": true,
    "suggestedContributionAmount": null,
    "createdUtc": "2026-06-30T15:37:55+00:00",
    "totalContributed": 0,
    "raisedAmount": 0,
    "potAmount": 0,
    "viewerRole": "GroupLeader",
    "displayStatus": "On Going",
    "projectInviteCode": "YXS9V5G8DZ",
    "roi": null,
    "pendingRequestCount": 0,
    "hasCoLeader": false
  },
  "rules": {
    "roiPercentage": null,
    "joinApprovalRequired": false,
    "borrowingAllowed": true,
    "successVoteWindowHours": 48,
    "repaymentWindowDays": 30,
    "penaltyPercentage": 30.0,
    "minimumContributionAmount": 5.0
  },
  "viewerMembership": {
    "membershipId": "fc2154f0-0c65-452c-b73b-0ce26135750f",
    "userId": "c90f3acd-5837-41c4-84ec-f58c6cf8cf59",
    "userName": "rajakumr",
    "firstName": "test",
    "lastName": "kdkdk",
    "photoURL": null,
    "role": "groupLead",
    "status": "active",
    "borrowLimitAmount": null,
    "isDefaulted": false,
    "badge": null,
    "overdueAmount": null,
    "VFFAdded": false,
    "vffConnectionState": "None",
    "canSendVffRequest": false,
    "pendingVffRequestId": null
  },
  "members": {
    "items": [
      {
        "membershipId": "fc2154f0-0c65-452c-b73b-0ce26135750f",
        "userId": "c90f3acd-5837-41c4-84ec-f58c6cf8cf59",
        "userName": "rajakumr",
        "firstName": "test",
        "lastName": "kdkdk",
        "photoURL": null,
        "role": "groupLead",
        "status": "active",
        "borrowLimitAmount": null,
        "isDefaulted": false,
        "badge": null,
        "overdueAmount": null,
        "VFFAdded": false,
        "vffConnectionState": "None",
        "canSendVffRequest": false,
        "pendingVffRequestId": null
      },
      {
        "membershipId": "ea6f4b46-b032-42d7-9aae-9890f34f8d84",
        "userId": "2e820ba5-1f36-4ce8-b8bd-af108c00e232",
        "userName": "mahazehra",
        "firstName": "maha",
        "lastName": "zehra",
        "photoURL": "https://vestiestorage.blob.core.windows.net/vestie-attachments/profile-pictures/example.jpg",
        "role": "member",
        "status": "active",
        "borrowLimitAmount": null,
        "isDefaulted": false,
        "badge": null,
        "overdueAmount": null,
        "VFFAdded": false,
        "vffConnectionState": "None",
        "canSendVffRequest": true,
        "pendingVffRequestId": null
      }
    ],
    "pagination": {
      "page": 1,
      "pageSize": 50,
      "totalCount": 2,
      "totalPages": 1
    }
  },
  "invites": {
    "items": [],
    "pagination": { "page": 1, "pageSize": 20, "totalCount": 0, "totalPages": 0 }
  },
  "announcements": {
    "items": [],
    "pagination": { "page": 1, "pageSize": 20, "totalCount": 0, "totalPages": 0 }
  },
  "projectStatus": "ongoing",
  "votingStatus": "pending",
  "userRole": "leader",
  "canStopContributions": false,
  "voting": {
    "startedAtUtc": "2026-06-30T17:55:23+00:00",
    "deadlineAtUtc": "2026-07-30T17:55:23+00:00",
    "agreedCount": 0,
    "disagreedCount": 0,
    "pendingCount": 1,
    "hasVoted": false,
    "isFinalized": false,
    "memberVotes": [
      {
        "membershipId": "ea6f4b46-b032-42d7-9aae-9890f34f8d84",
        "userId": "2e820ba5-1f36-4ce8-b8bd-af108c00e232",
        "displayName": "maha zehra",
        "voteStatus": "waiting"
      }
    ]
  }
}
```

**Mobile screens fed by this response:**

- Leader **View Success Votes** — tallies + Maha = **Waiting**
- Leader project detail — vote in progress (hide contribute/borrow as per rules)

---

### 7.2 Member — vote open, not voted yet (cast screen)

**Caller:** Member Maha (`userRole: "member"`, `viewerMembership.membershipId` = Maha's id)

Only the **Week 11 slice** shown; rest of response same as §7.1.

```json
{
  "projectStatus": "ongoing",
  "votingStatus": "pending",
  "userRole": "member",
  "canStopContributions": false,
  "viewerMembership": {
    "membershipId": "ea6f4b46-b032-42d7-9aae-9890f34f8d84",
    "userId": "2e820ba5-1f36-4ce8-b8bd-af108c00e232",
    "role": "member"
  },
  "voting": {
    "startedAtUtc": "2026-06-30T17:55:23+00:00",
    "deadlineAtUtc": "2026-07-30T17:55:23+00:00",
    "agreedCount": 0,
    "disagreedCount": 0,
    "pendingCount": 1,
    "hasVoted": false,
    "isFinalized": false,
    "memberVotes": [
      {
        "membershipId": "ea6f4b46-b032-42d7-9aae-9890f34f8d84",
        "userId": "2e820ba5-1f36-4ce8-b8bd-af108c00e232",
        "displayName": "maha zehra",
        "voteStatus": "waiting"
      }
    ]
  }
}
```

**Mobile:** Inline **cast vote** UI (Agree / Disagree buttons).

---

### 7.3 Member — after voting Agree (post-vote screen)

**After:** `POST /api/v1/projects/{id}/closure-voting/vote` with `{ "vote": "Yes" }`  
**Then:** `GET /api/v1/projects/{id}` returns:

```json
{
  "projectStatus": "ongoing",
  "votingStatus": "pending",
  "userRole": "member",
  "canStopContributions": false,
  "viewerMembership": {
    "membershipId": "ea6f4b46-b032-42d7-9aae-9890f34f8d84",
    "userId": "2e820ba5-1f36-4ce8-b8bd-af108c00e232",
    "role": "member"
  },
  "voting": {
    "startedAtUtc": "2026-06-30T17:55:23+00:00",
    "deadlineAtUtc": "2026-07-30T17:55:23+00:00",
    "agreedCount": 1,
    "disagreedCount": 0,
    "pendingCount": 0,
    "hasVoted": true,
    "isFinalized": false,
    "memberVotes": [
      {
        "membershipId": "ea6f4b46-b032-42d7-9aae-9890f34f8d84",
        "userId": "2e820ba5-1f36-4ce8-b8bd-af108c00e232",
        "displayName": "maha zehra",
        "voteStatus": "agreed"
      }
    ]
  }
}
```

**Mobile:**

- Member sees **post-vote** screen (Agreed banner, tallies, summary, Back to Home)
- Leader sees Maha as **Agreed** in View Success Votes

---

### 7.4 Member — voted Disagree

```json
{
  "voting": {
    "agreedCount": 0,
    "disagreedCount": 1,
    "pendingCount": 0,
    "hasVoted": true,
    "isFinalized": false,
    "memberVotes": [
      {
        "membershipId": "ea6f4b46-b032-42d7-9aae-9890f34f8d84",
        "userId": "2e820ba5-1f36-4ce8-b8bd-af108c00e232",
        "displayName": "maha zehra",
        "voteStatus": "disagreed"
      }
    ]
  }
}
```

---

### 7.5 Co-leader — same as member for cast / post-vote

**Caller:** `userRole: "co_leader"`  
Include co-leader in `memberVotes[]` when they are an eligible voter.  
`hasVoted` reflects whether **that co-leader** has voted.

---

### 7.6 Vote window ended — leader can finalize

**Caller:** `userRole: "leader"`  
**When:** `deadlineAtUtc` is in the past

```json
{
  "projectStatus": "ongoing",
  "votingStatus": "done",
  "userRole": "leader",
  "canStopContributions": false,
  "voting": {
    "startedAtUtc": "2026-06-30T17:55:23+00:00",
    "deadlineAtUtc": "2026-06-30T17:55:23+00:00",
    "agreedCount": 1,
    "disagreedCount": 0,
    "pendingCount": 0,
    "hasVoted": false,
    "isFinalized": false,
    "memberVotes": [
      {
        "membershipId": "ea6f4b46-b032-42d7-9aae-9890f34f8d84",
        "userId": "2e820ba5-1f36-4ce8-b8bd-af108c00e232",
        "displayName": "maha zehra",
        "voteStatus": "agreed"
      }
    ]
  }
}
```

**Mobile:** Leader sees **Finalize Decision** on detail / monitor when `votingStatus == "done"` and deadline passed.

---

### 7.7 After leader finalizes

```json
{
  "projectStatus": "completed",
  "votingStatus": "done",
  "userRole": "leader",
  "voting": {
    "agreedCount": 1,
    "disagreedCount": 0,
    "pendingCount": 0,
    "hasVoted": false,
    "isFinalized": true,
    "memberVotes": [
      {
        "membershipId": "ea6f4b46-b032-42d7-9aae-9890f34f8d84",
        "userId": "2e820ba5-1f36-4ce8-b8bd-af108c00e232",
        "displayName": "maha zehra",
        "voteStatus": "agreed"
      }
    ]
  }
}
```

---

### 7.8 No vote started

```json
{
  "projectStatus": "ongoing",
  "votingStatus": "not_started",
  "userRole": "leader",
  "canStopContributions": false
}
```

`voting` omitted or `null`.

---

## 8. Multi-member example (3 voters)

Vacation project with 1 leader + 3 members (only members vote):

```json
"voting": {
  "startedAtUtc": "2026-06-30T17:55:23+00:00",
  "deadlineAtUtc": "2026-07-30T17:55:23+00:00",
  "agreedCount": 1,
  "disagreedCount": 1,
  "pendingCount": 1,
  "hasVoted": false,
  "isFinalized": false,
  "memberVotes": [
    {
      "membershipId": "m1",
      "userId": "u1",
      "displayName": "Anna",
      "voteStatus": "agreed"
    },
    {
      "membershipId": "m2",
      "userId": "u2",
      "displayName": "James",
      "voteStatus": "disagreed"
    },
    {
      "membershipId": "m3",
      "userId": "u3",
      "displayName": "Sarah",
      "voteStatus": "waiting"
    }
  ]
}
```

---

## 9. Backend QA checklist

Before telling mobile “ready”, verify:

- [ ] `GET /projects/{id}` returns `memberVotes[]` whenever `votingStatus` is `pending` or `done`
- [ ] Group leader is **not** in `memberVotes[]` for vacation success vote
- [ ] `agreedCount` / `disagreedCount` / `pendingCount` match `memberVotes[]`
- [ ] `hasVoted` is **false** for leader on success vote
- [ ] `hasVoted` is **true** for member immediately after `POST …/vote`, before any cache delay
- [ ] Viewer's `voteStatus` in `memberVotes` matches their cast (`agreed` / `disagreed`)
- [ ] `viewerMembership.membershipId` matches the correct row in `memberVotes`
- [ ] After finalize, `isFinalized: true` and `projectStatus` updated as per business rules
- [ ] `votingStatus` becomes `done` when deadline passes (or document if mobile should infer from `deadlineAtUtc`)

---

## 10. What mobile will do after backend ships

**Mobile is already implemented** against this contract — no app logic changes are planned once backend matches §4–§7.

Locked by automated tests:

- `test/features/project_detail/project_detail_backend_voting_contract_test.dart`
- `test/features/project_detail/project_detail_week11_voting_test.dart`
- `test/leader/features/project_detail/leader_view_success_votes_cubit_test.dart`

We will:

1. Run QA on staging with leader + member test accounts
2. Confirm no fallback “all Waiting” behavior (requires `memberVotes[]`)
3. Confirm cast → reload → post-vote → leader monitor end-to-end

**Contact:** Share staging project id + test accounts (leader + member) when ready for mobile QA.

---

## 11. Related mobile docs

- `DOCS/qa/api_screen_sync_matrix.md` — Week 10–11 voting sync rows
- `lib/features/project_detail/feature_overview.md` — feature trace
- `DOCS/week_11_project_detail_voting_plan.md` — Week 11 implementation plan

---

## 12. Quick reference — API URLs (staging base)

```
BASE = https://vestie-backend-byexejcphyhaapfy.centralus-01.azurewebsites.net/api/v1

GET    {BASE}/projects/{projectId}
POST   {BASE}/projects/{projectId}/closure-voting/open
POST   {BASE}/projects/{projectId}/closure-voting/vote
POST   {BASE}/projects/{projectId}/closure-voting/finalize
GET    {BASE}/projects/{projectId}/closure-voting/active   (legacy fallback only)
```

**Primary update for this handoff:** `GET {BASE}/projects/{projectId}` → add `voting.memberVotes[]` and viewer-accurate `hasVoted`.
