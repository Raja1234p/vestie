# Backend handoff — Completed / rejected vote outcome UI

**Audience:** Vestie backend team  
**From:** Mobile (Flutter) — success-vote outcome screens + completed project detail  
**Date:** 2026-07-07  
**Status:** **Action required** — mobile works today with heuristics; explicit API fields needed for production reliability

**Related:** `DOCS/backend_handoff_project_detail_voting_api.md` (in-progress voting / cast / monitor)

---

## 1. What mobile shows

One shared layout (`SuccessVoteOutcomeScreen` / `ProjectDetailCompletedVoteOutcomeContent`) renders **different copy and styling** based on:

| Input | Source today | Drives |
|-------|----------------|--------|
| Project category | `project.type` | Vacation vs Emergency vs Investment strings |
| Viewer role | `userRole` / `viewerRole` | Leader vs co-leader vs member copy |
| Majority result | **Heuristic** on `displayStatus` | Approved vs rejected hero + amount card color |
| Vote variant | **Inferred** (investment only) | Success vote vs **stop-contributions rejected** |
| Refund phase | **Heuristic** on `displayStatus` | Refund in progress vs refund complete |
| Vote tallies | `voting.agreedCount` / `disagreedCount` | Vote summary rows |
| Amount | `project.potAmount` / `raisedAmount` | Amount card (`$9,800.00`) |

### 1.1 Where it appears

| Surface | When | API loaded |
|---------|------|------------|
| **Full-screen outcome** | Home / Profile completed card → **View** | `GET /projects/completed` or `GET /projects?scope=` row, then optional `GET /projects/{id}` on “View Details” |
| **Embedded in project detail** | `projectStatus = completed` (or cancelled) on detail | `GET /projects/{id}` |
| **After leader finalize** | Leader taps finalize after vote deadline | `POST …/closure-voting/finalize` response **then** reload `GET /projects/{id}` |

Detail screens that embed the outcome block:

- Vacation / Emergency member detail (completed)
- Investment detail (completed)
- Profile → Completed project detail

---

## 2. Outcome UI matrix (all Figma variants)

Mobile picks copy using **`category` + `viewerRole` + `isApproved` + `variant` + `refundPhase`**.

### 2.1 Vacation

| Result | Role | Title (example) | Amount caption (example) | CTA |
|--------|------|-----------------|--------------------------|-----|
| Approved | All | Project Approved! | Funds released to your wallet | Back to Home |
| Rejected (no refund) | All | Project Not Approved | Contributions being refunded | Back to Home |
| Rejected (refund) | All | Refund In Progress / Refund Complete | Refund copy | Back to Home |

### 2.2 Emergency

| Result | Role | Title (example) | Amount caption (example) | CTA |
|--------|------|-----------------|--------------------------|-----|
| Approved | Leader / co-leader / member | Project Approved! (role-specific amount) | Role-specific | Back to Home |
| Rejected | **All same copy** | **Project Not Resolved** | Emergency project continues. Review your group's goal and try again. | Back to Home |

### 2.3 Investment

| Result | Vote type | Role | Title (example) | Amount caption (example) | CTA |
|--------|-----------|------|-----------------|--------------------------|-----|
| Approved (final closure) | `FinalClosureVote` | Leader | Project Successful! | Distributions dispersed… | Back to Home |
| Approved (final closure) | `FinalClosureVote` | Co-leader / member | Returns Distributed! | Returns added to wallet | Back to Home |
| **Stop contributions failed** | `StopContributionsVote` | Leader | **Vote Not Passed** | Contributions continue on schedule. No investing phase yet. | Back to Home |
| **Stop contributions failed** | `StopContributionsVote` | Member | Vote Not Passed | No changes to your contribution schedule… | Back to Home |
| Success vote rejected | `SuccessVote` / `FinalClosureVote` | Leader | Project Not Approved | Contributions being refunded | **Resume Contributions** |
| Success vote rejected | `SuccessVote` / `FinalClosureVote` | Member | Project Not Approved | Contributions being refunded | Back to Home |
| Refund | Any | All | Refund In Progress / Complete | Refund copy | Back to Home |

**Vote summary order:** rejected outcomes show **Disagreed** row first, then **Agreed**.

---

## 3. How mobile decides today (and what breaks)

### 3.1 Approved vs rejected

```text
displayStatus contains "not approved" | "reject" | "refund" | "cancel"
  → rejected
else
  → approved
```

**Problems:**

- Fragile string matching; typos or new labels break UI.
- Investment **stop-contributions rejected** is not “completed” — project may still be `ongoing` with `displayStatus: "On Going"`.
- Refund vs plain rejection both use substring checks.

### 3.2 Investment stop-contributions rejected variant

```text
category == investment
AND displayStatus does NOT contain "funded"
AND outcome is rejected
  → "Vote Not Passed" UI
```

**Problems:**

- Infers vote type from **funded** display status instead of explicit `voteType`.
- If backend sets `displayStatus: "Project Not Approved"` on a still-ongoing investment, mobile may show the **wrong** rejection UI.

### 3.3 Vote tallies on completed detail

Mobile uses `voting.agreedCount` / `voting.disagreedCount` when `agreed + disagreed > 0`.

**Problems:**

- After project completes, backend may omit `voting` or zero out counts → vote summary hidden on detail.

### 3.4 List APIs (`GET /projects/completed`, home lists)

Mobile maps:

- `viewerRole` ✅ (used)
- `displayStatus` ✅ (used for approval heuristic)
- `memberCount` ← mapped from `maxMembers` today (**likely wrong**; should be eligible voter count)
- `successVoteApproved` ← **not sent by API today**; mobile falls back to `displayStatus` parsing

---

## 4. Required backend changes

### 4.1 Primary — extend `GET /api/v1/projects/{projectId}`

Add **persistent closure outcome fields** when a vote has been finalized (and keep `voting` tallies).

#### Top-level (recommended)

| Field | Type | Required when | Values |
|-------|------|---------------|--------|
| `projectStatus` | string | Always | `ongoing`, `completed`, `cancelled` |
| `canStopContributions` | bool | Investment | `true` until stop-contrib vote **passes** |

#### On `voting` object (extend existing schema)

| Field | Type | Required when | Description |
|-------|------|---------------|-------------|
| `voteType` | string | `votingStatus` is `pending` or `done` | `SuccessVote`, `StopContributionsVote`, `FinalClosureVote` |
| `outcome` | string | After finalize (`isFinalized: true`) | `Success`, `Refund`, `InvestmentStarted`, `Disputed` |
| `isApproved` | bool | After finalize | `true` if majority passed (`Success` or `InvestmentStarted`) |
| `agreedCount` | int | When vote exists / completed | Keep on completed projects |
| `disagreedCount` | int | When vote exists / completed | Keep on completed projects |
| `pendingCount` | int | When vote open | `0` after finalize |
| `eligibleVoterCount` | int | Recommended | Members + co-leaders who vote (excludes leader on vacation success vote) |
| `isFinalized` | bool | Always when `voting` present | `true` after leader finalize |

**Enum values** must match existing finalize API (`closure_voting_response_model.dart`):

```text
voteType:  SuccessVote | StopContributionsVote | FinalClosureVote
outcome:   Success | InvestmentStarted | Refund | Disputed
```

#### Derived rules mobile will use (once fields exist)

```text
isApproved      = voting.isApproved
                OR outcome in (Success, InvestmentStarted)

refund UI       = outcome == Refund
                OR projectStatus == cancelled

stop-contrib    = voteType == StopContributionsVote
rejected UI       AND isApproved == false
```

#### `project.displayStatus` — canonical labels

Keep human-readable `displayStatus`, but mobile will **prefer** `voting.outcome` / `voting.isApproved`. Please use stable strings:

| Scenario | Suggested `displayStatus` |
|----------|---------------------------|
| Ongoing, contributions open | `On Going` |
| Investment, stop-contrib passed | `Funded` |
| Completed, success vote passed | `Completed` or `Project Approved` |
| Completed, success vote failed | `Project Not Approved` |
| Refund processing | `Refund in progress` |
| Refund done | `Refund complete` |
| Emergency rejected (ongoing) | `On Going` (outcome still in `voting`) |

---

### 4.2 List APIs — `GET /projects/completed` and `GET /projects?scope=`

Each project row should include enough to open the correct outcome **before** detail load:

| Field | Type | Description |
|-------|------|-------------|
| `viewerRole` | string | `GroupLeader`, `CoLeader`, `Member` (already used) |
| `type` | string | `vacation`, `emergency`, `investment` |
| `displayStatus` | string | Keep for chips; see §4.1 |
| `raisedAmount` / `potAmount` | number | Amount card |
| **`memberCount`** | int | **Eligible voters** in last finalized vote (not `maxMembers`) |
| **`lastVoteType`** | string | Same enum as `voting.voteType` |
| **`lastVoteOutcome`** | string | Same enum as `voting.outcome` |
| **`successVoteApproved`** | bool | `true` if last finalized vote passed |

Mobile will map `successVoteApproved` directly when present and stop parsing `displayStatus` for approval.

---

### 4.3 Finalize response alignment

`POST /projects/{id}/closure-voting/finalize` already returns `voteType`, `outcome`, tallies.

**Requirement:** The same `voteType`, `outcome`, and tallies must appear on the **next** `GET /projects/{id}` (and list rows after completion).

---

## 5. Example responses

### 5.1 Investment — stop-contributions vote **rejected** (leader) — project still ongoing

Mobile shows **Vote Not Passed** embedded or full-screen.

```json
{
  "projectStatus": "ongoing",
  "votingStatus": "done",
  "userRole": "leader",
  "canStopContributions": true,
  "project": {
    "id": "…",
    "type": "investment",
    "displayStatus": "On Going",
    "potAmount": 9800.0,
    "targetAmount": 15000.0
  },
  "voting": {
    "voteType": "StopContributionsVote",
    "outcome": "Disputed",
    "isApproved": false,
    "isFinalized": true,
    "agreedCount": 2,
    "disagreedCount": 5,
    "pendingCount": 0,
    "eligibleVoterCount": 7,
    "startedAtUtc": "2026-07-01T12:00:00Z",
    "deadlineAtUtc": "2026-07-03T12:00:00Z",
    "hasVoted": false,
    "memberVotes": []
  }
}
```

> `outcome: "Disputed"` or a dedicated `Rejected` value is fine if `isApproved: false`. Mobile treats any non-success outcome as rejected.

### 5.2 Vacation — success vote **rejected** with refund in progress

```json
{
  "projectStatus": "completed",
  "votingStatus": "done",
  "userRole": "member",
  "project": {
    "type": "vacation",
    "displayStatus": "Refund in progress",
    "potAmount": 9800.0
  },
  "voting": {
    "voteType": "SuccessVote",
    "outcome": "Refund",
    "isApproved": false,
    "isFinalized": true,
    "agreedCount": 2,
    "disagreedCount": 5,
    "pendingCount": 0,
    "eligibleVoterCount": 7
  }
}
```

### 5.3 Emergency — success vote **rejected**, project continues

```json
{
  "projectStatus": "ongoing",
  "votingStatus": "done",
  "userRole": "co_leader",
  "project": {
    "type": "emergency",
    "displayStatus": "On Going",
    "potAmount": 9800.0
  },
  "voting": {
    "voteType": "SuccessVote",
    "outcome": "Disputed",
    "isApproved": false,
    "isFinalized": true,
    "agreedCount": 2,
    "disagreedCount": 5,
    "pendingCount": 0,
    "eligibleVoterCount": 7
  }
}
```

### 5.4 Investment — final closure **approved**

```json
{
  "projectStatus": "completed",
  "votingStatus": "done",
  "userRole": "leader",
  "canStopContributions": false,
  "project": {
    "type": "investment",
    "displayStatus": "Completed",
    "potAmount": 9800.0
  },
  "voting": {
    "voteType": "FinalClosureVote",
    "outcome": "InvestmentStarted",
    "isApproved": true,
    "isFinalized": true,
    "agreedCount": 6,
    "disagreedCount": 1,
    "pendingCount": 0,
    "eligibleVoterCount": 7
  }
}
```

### 5.5 Completed list row (minimal)

```json
{
  "id": "…",
  "name": "Growth Fund",
  "type": "investment",
  "displayStatus": "On Going",
  "raisedAmount": 9800.0,
  "viewerRole": "GroupLeader",
  "memberCount": 7,
  "lastVoteType": "StopContributionsVote",
  "lastVoteOutcome": "Disputed",
  "successVoteApproved": false
}
```

---

## 6. Acceptance checklist (backend QA)

- [ ] After finalize, `GET /projects/{id}` returns `voting.voteType`, `voting.outcome`, `voting.isApproved`, tallies.
- [ ] Completed projects still return non-zero `agreedCount` / `disagreedCount`.
- [ ] Investment stop-contrib **failed**: `canStopContributions` stays `true`, `displayStatus` does not become `Funded`.
- [ ] Investment stop-contrib **passed**: `canStopContributions` becomes `false`, `displayStatus` includes `Funded`.
- [ ] `GET /projects/completed` rows include `successVoteApproved`, `lastVoteType`, `lastVoteOutcome`, correct `memberCount`.
- [ ] `userRole` / `viewerRole` aligned with caller membership on detail and list.
- [ ] Refund lifecycle updates `displayStatus` (`Refund in progress` → `Refund complete`) **and** `outcome: Refund`.

---

## 7. Mobile follow-up (after backend ships)

When `voting.isApproved`, `voting.voteType`, and `voting.outcome` are present on detail + list:

1. Replace `displayStatus` substring heuristics in `project_detail_completed_outcome_extensions.dart` and `Project.isSuccessVoteApproved`.
2. Map `successVoteApproved` / `lastVoteType` / `lastVoteOutcome` in `projects_repository_impl.dart`.
3. Parse `voting.voteType` / `voting.outcome` in `project_detail_response_model.dart` (fields are listed as optional in the Week 11 handoff but not wired for completed outcome).
4. Update `DOCS/qa/api_screen_sync_matrix.md` rows for completed / outcome screens.

Until then, mobile uses the heuristics documented in §3.

---

## 8. Summary

| Question | Answer |
|----------|--------|
| Does mobile need backend changes? | **Yes** — for reliable outcome UI on detail and list |
| Which API? | **`GET /projects/{id}`** (primary), **`GET /projects/completed`**, home **`GET /projects?scope=`** |
| Minimum new fields | `voting.voteType`, `voting.outcome`, `voting.isApproved`, persist tallies; list: `successVoteApproved`, `lastVoteType`, `lastVoteOutcome`, correct `memberCount` |
| Can we ship with `displayStatus` only? | **Risky** — investment stop-contrib rejected and emergency “not resolved” are easy to misclassify |
