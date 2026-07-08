# Backend handoff — Completed / rejected vote outcome UI

**Audience:** Vestie backend team  
**From:** Mobile (Flutter) — success-vote outcome screens  
**Date:** 2026-07-07  
**Status:** **Action required** — mobile works today with heuristics; explicit API fields needed for production reliability

**Related:** `DOCS/backend_handoff_project_detail_voting_api.md` (in-progress voting / cast / monitor)

---

## 1. What mobile shows

**Primary surface:** `SuccessVoteOutcomeScreen` (`AppSuccessScreen` — white background, top illustration, **no post-auth gradient header**). Completed card **View** loads `GET /projects/{id}` via `SuccessVoteOutcomeLoadScreen`, then renders API-driven copy.

One shared layout renders **different copy and styling** based on:

| Input | Source (production) | Drives |
|-------|---------------------|--------|
| Project category | `project.type` | Vacation vs Emergency vs Investment strings |
| Viewer role | `userRole` / `viewerRole` | Leader vs co-leader vs member copy |
| Majority result | `voting.isApproved` / `voting.outcome` | Approved vs rejected hero + amount card color |
| Vote variant | `voting.voteType` | Success vote vs **stop-contributions rejected** |
| Refund phase | `voting.voteType` + `voting.outcome` + `displayStatus` | **Investment stop-contributions** vote passed with **Refund Me** majority only |
| Distribution phase | `voting.distributionStatus` | Leader distribution titles vs member Returns Distributed! |
| Vote tallies | `voting.agreedCount` / `disagreedCount` | Vote summary rows |
| Amount | `project.potAmount` / `raisedAmount` | Amount card (`$9,800.00`) |

### 1.1 Where it appears

| Surface | When | API loaded |
|---------|------|------------|
| **Full-screen outcome** | Home / Profile completed card → **View** | `GET /projects/{id}` (load screen) |
| **Full-screen outcome** | Direct open of completed vacation / emergency / investment detail | `GET /projects/{id}` (detail bloc) → `SuccessVoteOutcomeScreen` |
| **Full-screen outcome** | Profile route `/profile/completed-projects/detail` (deep link / legacy path) | `GET /projects/{id}` (load screen) |
| **After leader finalize** | Leader taps finalize after vote deadline | `POST …/finalize` then `GET /projects/{id}` |
| **Stop-contributions rejected** | Investment detail while project still `ongoing` | `GET /projects/{id}` → full-screen **Vote Not Passed** |
| **Stop-contributions passed** | Investment detail, `lifecycleState: funded`, `canStopContributions: false` | `GET /projects/{id}` → **Distribute Funds / Investment Returns** on detail (not outcome screen) |

**CTA:** **Back to Home** → dashboard (all Figma outcome variants). No gradient-header embedded outcome UI.

---

## 2. Outcome UI matrix (all Figma variants)

Mobile picks copy using **`category` + `viewerRole` + `isApproved` + `variant` + `refundPhase`**.

### 2.1 Vacation

| Result | Role | Title | Subtitle | Amount caption | CTA |
|--------|------|-------|----------|----------------|-----|
| Approved | Leader | Project Approved! | Majority of members agreed. | Funds released to your wallet | Back to Home |
| Approved | Co-leader / member | Project Approved! | Majority of members agreed. | Funds released to the project leader | Back to Home |
| Rejected (leader) | Leader | Project Not Approved | Majority of members disagreed. | Contributions being refunded | Back to Home |
| Rejected (member) | Co-leader / member | Project Not Approved | Majority of members disagreed. | Your contributions are being refunded to your wallet. | Back to Home |

> Vacation has **no** separate Refund In Progress / Refund Complete screens — rejected copy only (amount caption mentions refund).

### 2.2 Emergency

| Result | Role | Title | Subtitle | Amount caption | CTA |
|--------|------|-------|----------|----------------|-----|
| Approved | Co-leader / member | Project Resolved! | Majority of members agreed. | Emergency project closed. Unused funds released to leader. | Back to Home |
| Approved | Leader | Project Approved! | Majority of members agreed. | Unused emergency funds released to your wallet | Back to Home |
| Rejected (leader) | Leader | Project Not Approved | Majority of members disagreed. | Contributions being refunded | Back to Home |
| Rejected (member) | Co-leader / member | Project Not Approved | Majority of members disagreed. | Your contributions are being refunded to your wallet. | Back to Home |

> Emergency rejected copy matches vacation (§2.1) — approved copy remains emergency-specific.

### 2.3 Investment

| Result | Vote type | Role | Title | Subtitle | Amount caption | CTA |
|--------|-----------|------|-------|----------|----------------|-----|
| Approved (legacy) | `FinalClosureVote` | Leader | Project Successful! | Majority of members agreed. | Your dividends have been distributed to all the members in the group. | Back to Home |
| Distribution processing | `FinalClosureVote` | **Leader only** | Distributions In Progress | Majority of members agreed. | Investment returns are being calculated… | Back to Home |
| Distribution done | `FinalClosureVote` | **Leader only** | Distribution Complete | Majority of members agreed. | All investment returns have been distributed… | Back to Home |
| Returns received | `FinalClosureVote` | Co-leader / member | Returns Distributed! | Majority of members agreed. | Your investment returns have been distributed and added to your wallet. | Back to Home |
| **Stop contributions passed (refund)** | `StopContributionsVote` | All | Refund In Progress / Refund Complete | (refund copy) | (refund amount caption) | Back to Home |
| **Stop contributions failed** | `StopContributionsVote` | Leader | Vote Not Passed | Majority chose to keep contributing. | Contributions continue on schedule. No investing phase yet. | Back to Home |
| **Stop contributions failed** | `StopContributionsVote` | Member | Vote Not Passed | Majority voted to keep contributing. | No changes to your contribution schedule. Keep contributing as planned | Back to Home |
| Success / final closure rejected | `SuccessVote` / `FinalClosureVote` | Leader | Project Not Approved | Majority of members disagreed. | Contributions being refunded | Back to Home |
| Success / final closure rejected | `SuccessVote` / `FinalClosureVote` | Member | Project Not Approved | Majority of members disagreed. | Your contributions are being refunded to your wallet. | Back to Home |

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
| **`distributionStatus`** | string | Investment final closure **approved** | `InProgress`, `Complete`, `None` — drives leader “Distributions In Progress” / “Distribution Complete” UI |

**Enum values** must match existing finalize API (`closure_voting_response_model.dart`):

```text
voteType:  SuccessVote | StopContributionsVote | FinalClosureVote
outcome:   Success | InvestmentStarted | Refund | Disputed
```

#### Derived rules mobile will use (once fields exist)

```text
isApproved      = voting.isApproved
                OR outcome in (Success, InvestmentStarted)

refund UI       = category == investment
                AND voteType == StopContributionsVote
                AND outcome == Refund

stop-contrib    = voteType == StopContributionsVote
rejected UI       AND isApproved == false

leader distribution UI = category == investment
                      AND isApproved == true
                      AND voteType == FinalClosureVote (or outcome InvestmentStarted)
                      AND distributionStatus in (InProgress, Complete)
                      AND viewerRole == GroupLeader

member/co-leader investment approved final closure
                      → Returns Distributed! (ignores distributionStatus for title)
```

**`distributionStatus` values (preferred wire format):**

| Value | Leader UI title |
|-------|-----------------|
| `InProgress` | Distributions In Progress |
| `Complete` | Distribution Complete |
| `None` / omitted | Falls back to `displayStatus` keywords, then legacy “Project Successful!” |

**`displayStatus` fallbacks** (if `distributionStatus` omitted): `Distributions In Progress`, `Distribution Complete`, `Distribution in progress`, etc.

#### `project.displayStatus` — canonical labels

Keep human-readable `displayStatus`, but mobile will **prefer** `voting.outcome` / `voting.isApproved`. Please use stable strings:

| Scenario | Suggested `displayStatus` |
|----------|---------------------------|
| Ongoing, contributions open | `On Going` |
| Investment, stop-contrib passed | `Funded` |
| Completed, success vote passed | `Completed` or `Project Approved` |
| Investment, distributions processing | `Distributions In Progress` |
| Investment, all returns sent | `Distribution Complete` |
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
| **`distributionStatus`** | string | `InProgress` \| `Complete` \| `None` — investment leader distribution UI |

Mobile will map `successVoteApproved` directly when present and stop parsing `displayStatus` for approval.

---

### 4.3 Finalize response alignment

`POST /projects/{id}/closure-voting/finalize` already returns `voteType`, `outcome`, tallies.

**Requirement:** The same `voteType`, `outcome`, and tallies must appear on the **next** `GET /projects/{id}` (and list rows after completion).

---

## 5. Example responses

### 5.1 Investment — stop-contributions vote **rejected** (leader) — project still ongoing

Mobile shows **Vote Not Passed** full-screen (`SuccessVoteOutcomeScreen`).

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

### 5.2 Investment — stop-contributions vote **passed** with refund (Refund Me majority)

```json
{
  "projectStatus": "completed",
  "votingStatus": "done",
  "userRole": "member",
  "project": {
    "type": "investment",
    "displayStatus": "Refund in progress",
    "potAmount": 9800.0
  },
  "voting": {
    "voteType": "StopContributionsVote",
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
    "distributionStatus": "InProgress",
    "agreedCount": 6,
    "disagreedCount": 1,
    "pendingCount": 0,
    "eligibleVoterCount": 7
  }
}
```

Mobile leader UI: **Distributions In Progress** / caption *Investment returns are being calculated…*

### 5.5 Investment — final closure approved, distributions **complete**

```json
{
  "projectStatus": "completed",
  "votingStatus": "done",
  "userRole": "leader",
  "project": {
    "type": "investment",
    "displayStatus": "Distribution Complete",
    "potAmount": 9800.0
  },
  "voting": {
    "voteType": "FinalClosureVote",
    "outcome": "InvestmentStarted",
    "isApproved": true,
    "isFinalized": true,
    "distributionStatus": "Complete",
    "agreedCount": 6,
    "disagreedCount": 1,
    "pendingCount": 0,
    "eligibleVoterCount": 7
  }
}
```

Mobile leader UI: **Distribution Complete** / caption *All investment returns have been distributed…*

### 5.6 Completed list row (minimal)

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

Investment approved list row should also include `"distributionStatus": "InProgress"` or `"Complete"` when applicable.

---

## 6. Acceptance checklist (backend QA)

- [ ] After finalize, `GET /projects/{id}` returns `voting.voteType`, `voting.outcome`, `voting.isApproved`, tallies.
- [ ] Completed projects still return non-zero `agreedCount` / `disagreedCount`.
- [ ] Investment stop-contrib **failed**: `canStopContributions` stays `true`, `displayStatus` does not become `Funded`.
- [ ] Investment stop-contrib **passed**: `canStopContributions` becomes `false`, `displayStatus` includes `Funded`.
- [ ] `GET /projects/completed` rows include `successVoteApproved`, `lastVoteType`, `lastVoteOutcome`, correct `memberCount`.
- [ ] Investment final closure approved: `voting.distributionStatus` transitions `InProgress` → `Complete` (or `displayStatus` uses distribution labels).
- [ ] `userRole` / `viewerRole` aligned with caller membership on detail and list.
- [ ] Refund lifecycle updates `displayStatus` (`Refund in progress` → `Refund complete`) **and** `outcome: Refund`.

---

## 7. Mobile follow-up (after backend ships)

When `voting.isApproved`, `voting.voteType`, and `voting.outcome` are present on detail + list:

1. ~~Replace `displayStatus` substring heuristics~~ — **Done (2026-07-07):** prefers API envelope, falls back to legacy `displayStatus`.
2. ~~Map `successVoteApproved` / `lastVoteType` / `lastVoteOutcome` in list repository~~ — **Done.**
3. ~~Parse `voting.voteType` / `voting.outcome` in `project_detail_response_model.dart`~~ — **Done.**
4. Detail shows outcome block when `voting.isFinalized` + outcome envelope, even if `projectStatus` is still `ongoing` (investment stop-contrib rejected, emergency not resolved).
5. **Investment leader distribution UI** — `distributionStatus` / `displayStatus` → Distributions In Progress \| Distribution Complete (**Done 2026-07-08**).
6. Update `DOCS/qa/api_screen_sync_matrix.md` when QA validates against staging.

Until backend ships the new fields, mobile continues to use the §3 heuristics as fallback.

---

## 8. Summary

| Question | Answer |
|----------|--------|
| Does mobile need backend changes? | **Yes** — for reliable outcome UI on detail and list |
| Which API? | **`GET /projects/{id}`** (primary), **`GET /projects/completed`**, home **`GET /projects?scope=`** |
| Minimum new fields | `voting.voteType`, `voting.outcome`, `voting.isApproved`, `voting.distributionStatus`, persist tallies; list: `successVoteApproved`, `lastVoteType`, `lastVoteOutcome`, `distributionStatus`, correct `memberCount` |
| Can we ship with `displayStatus` only? | **Risky** — investment stop-contrib rejected and emergency “not resolved” are easy to misclassify |
