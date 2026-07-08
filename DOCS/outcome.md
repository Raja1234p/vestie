# Vestie — Vote outcome API (backend handoff)

**Audience:** Vestie backend team  
**From:** Mobile (Flutter)  
**Date:** 2026-07-09  
**Status:** **Action required** — mobile ships outcome UI; backend must return explicit `voting` envelope + stable `displayStatus`

> **Share this file only** with backend. Mobile behavior is fully defined here — no other doc is required to implement.

**Out of scope:** in-progress cast / monitor / finalize voting mechanics — see `DOCS/backend_handoff_project_detail_voting_api.md` only if needed.

---

## 0. Quick reference

### APIs to update

| API | Purpose |
|-----|---------|
| **`GET /api/v1/projects/{projectId}`** | Primary — outcome screen + project detail |
| **`GET /projects/completed`** | Completed list → **View** opens outcome (or detail — see §1.2) |
| **`GET /projects?scope=`** (home lists) | Same list fields as completed |
| **`POST …/closure-voting/finalize`** | Must persist same `voteType` / `outcome` / tallies on next GET |

### Wire enums (must match exactly)

```text
voteType:  SuccessVote | StopContributionsVote | FinalClosureVote
outcome:   Success | InvestmentStarted | Refund | Disputed | NoVotes
```

| Field | Detail `GET /projects/{id}` | List `viewerRole` |
|-------|----------------------------|-------------------|
| Leader | `userRole`: `leader` | `GroupLeader` |
| Co-leader | `userRole`: `co_leader` | `CoLeader` |
| Member | `member` (default) | `Member` |
| Vacation | `project.type`: `vacation` | `vacation` |
| Emergency | `emergency` | `emergency` |
| Investment | `investment` | `investment` |

### Decision tree (after finalize)

```text
vacation | emergency + SuccessVote + isApproved=true
  → projectStatus: completed | cancelled
  → displayStatus: Completed | Project Approved
  → outcome: Success
  → mobile: full-screen APPROVED outcome

vacation | emergency + SuccessVote + isApproved=false (majority disagreed)
  → projectStatus: completed | cancelled  (NOT ongoing)
  → displayStatus: Project Not Approved
  → outcome: Disputed
  → agreedCount + disagreedCount > 0
  → mobile: full-screen REJECTED outcome (vote summary shown)
  → NO Refund in progress / Refund complete

vacation | emergency | investment stop-contrib + deadline, ZERO votes cast
  → agreedCount: 0, disagreedCount: 0  (and/or outcome: NoVotes)
  → isApproved: false
  → displayStatus: Project Not Approved
  → outcome: NoVotes  (preferred) or Disputed with zero tallies
  → mobile: full-screen NO ONE VOTED outcome (§2.4) — NOT majority-disagreed copy
  → vote summary HIDDEN

investment + StopContributionsVote + outcome=Refund (Refund Me passed)
  → displayStatus: Refund in progress → Refund complete
  → ONLY investment stop-contrib uses refund-phase labels

investment + StopContributionsVote + isApproved=false (keep contributing)
  → projectStatus: ongoing
  → displayStatus: On Going
  → canStopContributions: true
  → agreedCount + disagreedCount > 0
  → mobile: full-screen Vote Not Passed

investment + StopContributionsVote + isApproved=true (Start Investing passed)
  → projectStatus: ongoing
  → lifecycleState: funded
  → displayStatus: Funded
  → canStopContributions: false
  → outcome: InvestmentStarted  (preferred) or Success
  → mobile: NO outcome screen — Distribute Funds / Investment Returns on detail

investment + FinalClosureVote + isApproved=true (final success, votes cast)
  → projectStatus: completed
  → displayStatus: Completed | Distribution Complete
  → outcome: InvestmentStarted
  → mobile: full-screen SUCCESS outcome — SAME copy for leader / co-leader / member
  → distributionStatus optional (detail only; outcome screen ignores it)

investment + FinalClosureVote + ZERO votes (mark successful, no participation)
  → isApproved: true
  → outcome: InvestmentStarted  (preferred) OR NoVotes with zero tallies
  → projectStatus: ongoing  (NOT completed)
  → lifecycleState: funded
  → displayStatus: Funded
  → canStopContributions: false
  → mobile: NO outcome screen — same as No Dispute
  → Distribute Funds (leader) / Investment Returns (member) on project detail

investment + FinalClosureVote | SuccessVote + isApproved=false (majority disagreed)
  → displayStatus: Project Not Approved
  → agreedCount + disagreedCount > 0
  → mobile: full-screen REJECTED outcome (like vacation rejected)
```

---

## 1. What mobile shows

**Primary surface:** `SuccessVoteOutcomeScreen` — white background, top illustration, **no post-auth gradient header**. **CTA:** Back to Home.

Mobile picks copy using **`category` + `viewerRole` + `isApproved` + `voteType` + `outcome` + no-votes detection**.

| Input | API source | Drives |
|-------|-----------|--------|
| Project category | `project.type` | Vacation / Emergency / Investment strings |
| Viewer role | `userRole` / `viewerRole` | Leader vs co-leader vs member copy |
| Majority result | `voting.isApproved` / `voting.outcome` | Approved vs rejected hero |
| Vote type | `voting.voteType` | Success vs stop-contrib vs final closure |
| No votes | `outcome: NoVotes` OR `agreedCount==0 && disagreedCount==0` | No One Voted UI (§2.4) |
| Refund phase | `voteType` + `outcome: Refund` + `displayStatus` | Investment stop-contrib refund only |
| Vote tallies | `agreedCount` / `disagreedCount` | Vote summary (hidden for no-votes) |
| Amount | `potAmount` / `raisedAmount` | Amount card |

### 1.1 When full-screen outcome appears

| Scenario | Mobile surface |
|----------|----------------|
| Vacation / emergency approved or rejected (with votes) | Full-screen outcome |
| Vacation / emergency **no votes** | Full-screen **No One Voted** outcome |
| Investment stop-contrib rejected (keep contributing) | Full-screen **Vote Not Passed** |
| Investment stop-contrib **no votes** | Full-screen **No One Voted** |
| Investment stop-contrib refund passed | Full-screen refund lifecycle |
| Investment final closure **approved** (with votes) | Full-screen **Project Successfully completed!** |
| Investment final closure **rejected** (majority disagreed) | Full-screen **Project Not Approved** |
| Investment final closure **no votes** | **No outcome screen** — project detail with Distribute / Returns |
| Investment stop-contrib **passed** (start investing) | **No outcome screen** — project detail Funded |

### 1.2 List **View** routing

| List row signals | Opens |
|------------------|-------|
| `successVoteApproved: true/false` + normal completed | Outcome load screen → `GET /projects/{id}` → outcome |
| `type: investment` + `lastVoteType: FinalClosureVote` + `lastVoteOutcome: NoVotes` | Project detail (funded) — **not** outcome |
| Investment `ongoing` + `displayStatus: Funded` | Project detail (Distribute / Returns) |

---

## 2. Outcome UI matrix (all variants)

### 2.1 Vacation

| Result | Role | Title | Subtitle | Amount caption |
|--------|------|-------|----------|----------------|
| Approved | Leader | Project Approved! | Majority of members agreed. | Funds released to your wallet |
| Approved | Co-leader / member | Project Approved! | Majority of members agreed. | Funds released to the project leader |
| Rejected | Leader | Project Not Approved | Majority of members disagreed. | Contributions being refunded |
| Rejected | Co-leader / member | Project Not Approved | Majority of members disagreed. | Your contributions are being refunded to your wallet. |

> **No** Refund In Progress / Refund Complete screens for vacation.

### 2.2 Emergency

| Result | Role | Title | Subtitle | Amount caption |
|--------|------|-------|----------|----------------|
| Approved | Co-leader / member | Project Resolved! | Majority of members agreed. | Emergency project closed. Unused funds released to leader. |
| Approved | Leader | Project Approved! | Majority of members agreed. | Unused emergency funds released to your wallet |
| Rejected | Leader | Project Not Approved | Majority of members disagreed. | Contributions being refunded |
| Rejected | Co-leader / member | Project Not Approved | Majority of members disagreed. | Your contributions are being refunded to your wallet. |

> **Same rejected contract as vacation** — only `project.type` differs. **No** refund-phase `displayStatus`.

### 2.3 Investment

| Result | Vote type | Role | Title | Subtitle | Amount caption |
|--------|-----------|------|-------|----------|----------------|
| **Final closure approved** | `FinalClosureVote` | **All roles** | Project Successfully completed! | Majority of members agreed. | Total Funds distributed to all the contributors |
| **Stop contrib passed (refund)** | `StopContributionsVote` | All | Refund In Progress → Refund Complete | Your refund is being processed. → All contributions have been returned. | Funds will appear in your wallet within 1–3 business days → Your full contribution has been added to your wallet |
| **Stop contrib failed** | `StopContributionsVote` | Leader | Vote Not Passed | Majority chose to keep contributing. | Contributions continue on schedule. No investing phase yet. |
| **Stop contrib failed** | `StopContributionsVote` | Member | Vote Not Passed | Majority voted to keep contributing. | No changes to your contribution schedule. Keep contributing as planned |
| **Final closure rejected** | `FinalClosureVote` | Leader / member | Project Not Approved | Majority of members disagreed. | Contributions being refunded / wallet refund |
| **Stop contrib passed (invest)** | `StopContributionsVote` | — | — | — | **No outcome screen** — detail shows Funded + Distribute / Returns |

> **No** Distributions In Progress / Distribution Complete on the **outcome screen**. `distributionStatus` is for **project detail** Distribute Funds flow only.

**Vote summary order:** rejected outcomes show **Disagreed** first, then **Agreed**. **No-votes** hides vote summary entirely.

### 2.4 No votes cast (deadline ended, zero participation)

**Detection (mobile):**

```text
isFinalized == true
AND (
  outcome == NoVotes
  OR (agreedCount == 0 AND disagreedCount == 0)
)
```

| Project | Vote type | Role | Title | Subtitle | Amount caption | Vote summary |
|---------|-----------|------|-------|----------|----------------|--------------|
| Vacation / Emergency | `SuccessVote` | Leader | No One Voted | The voting deadline passed without any members casting a vote. | All contributions are being refunded | **Hidden** |
| Vacation / Emergency | `SuccessVote` | Co-leader / member | No One Voted | (same subtitle) | Your contributions are being refunded to your wallet | **Hidden** |
| Investment | `StopContributionsVote` | Leader | No One Voted | (same subtitle) | All contributions are being refunded | **Hidden** |
| Investment | `StopContributionsVote` | Co-leader / member | No One Voted | (same subtitle) | Your contributions are being refunded to your wallet | **Hidden** |
| Investment | `FinalClosureVote` | **All** | — | — | — | **No outcome screen** |

> **Critical:** No-votes is **not** majority-disagreed rejected copy. Send explicit `outcome: NoVotes` or zero tallies — do not rely on `Disputed` alone when counts are zero.

**`isApproved` for no-votes:**

| Vote type | `isApproved` | `outcome` (preferred) |
|-----------|--------------|------------------------|
| `SuccessVote` (vacation / emergency) | `false` | `NoVotes` |
| `StopContributionsVote` | `false` | `NoVotes` |
| `FinalClosureVote` (mark successful) | **`true`** | `InvestmentStarted` or `NoVotes` |

---

## 3. Required API fields

### 3.1 `GET /api/v1/projects/{projectId}` — detail

#### Top-level

| Field | Type | Required when | Values |
|-------|------|---------------|--------|
| `projectStatus` | string | Always | `ongoing`, `completed`, `cancelled` |
| `canStopContributions` | bool | Investment | `false` after stop-contrib vote passes |
| `votingStatus` | string | When vote exists | `pending`, `done` |
| `userRole` | string | Always | `leader`, `co_leader`, `member` |

#### `project` object

| Field | Type | Notes |
|-------|------|-------|
| `type` | string | `vacation`, `emergency`, `investment` |
| `displayStatus` | string | Human-readable — see §3.3 |
| `potAmount` / `raisedAmount` | number | Outcome amount card |
| `lifecycleState` | string | `active`, `funded`, etc. — investment no-votes final closure → **`funded`** |

#### `voting` object (extend existing schema)

| Field | Type | Required when | Description |
|-------|------|---------------|-------------|
| `voteType` | string | Vote exists | `SuccessVote`, `StopContributionsVote`, `FinalClosureVote` |
| `outcome` | string | After finalize | `Success`, `Refund`, `InvestmentStarted`, `Disputed`, **`NoVotes`** |
| `isApproved` | bool | After finalize | `true` for `Success`, `InvestmentStarted`; `false` for `Disputed`, `Refund`, `NoVotes` — **except** investment `FinalClosureVote` no-votes → `true` |
| `isFinalized` | bool | When `voting` present | `true` after deadline finalize |
| `agreedCount` | int | Always when vote exists | **Keep on completed GET** — may be `0` for no-votes |
| `disagreedCount` | int | Always when vote exists | **Keep on completed GET** — may be `0` for no-votes |
| `pendingCount` | int | When vote open | `0` after finalize |
| `eligibleVoterCount` | int | Recommended | Eligible voters (not `maxMembers`) |
| `distributionStatus` | string | Investment optional | `InProgress`, `Complete`, `None` — **detail only** |

#### Mobile derivation rules

```text
noVotes         = isFinalized
                AND (outcome == NoVotes
                     OR (agreedCount == 0 AND disagreedCount == 0))

noVotes UI      = noVotes == true
                AND voteType != FinalClosureVote
                → No One Voted screen (§2.4)

finalClosure    = noVotes == true
noVotes detail    AND voteType == FinalClosureVote
                AND isApproved == true
                → NO outcome screen; Funded detail + Distribute / Returns

isApproved      = voting.isApproved
                OR outcome in (Success, InvestmentStarted)

refund UI       = type == investment
                AND voteType == StopContributionsVote
                AND outcome == Refund

stop-contrib    = voteType == StopContributionsVote
passed (invest)   AND isApproved == true
                AND outcome in (Success, InvestmentStarted)
                AND displayStatus: Funded / lifecycleState: funded
                → NO outcome screen; Distribute / Returns on detail

stop-contrib    = voteType == StopContributionsVote
rejected          AND isApproved == false
                AND NOT noVotes
                → Vote Not Passed

vacation /      = type in (vacation, emergency)
emergency         AND voteType == SuccessVote
rejected          AND isApproved == false
                AND NOT noVotes
                → Project Not Approved (with vote summary)

vacation /      = type in (vacation, emergency)
emergency         AND voteType == SuccessVote
noVotes           AND noVotes == true
                → No One Voted (no vote summary)

investment      = type == investment
final approved    AND voteType == FinalClosureVote
                  AND isApproved == true
                  AND NOT (noVotes AND zero tallies with Funded ongoing)
                → Project Successfully completed! (all roles, one screen)
```

### 3.2 List APIs — `GET /projects/completed` and `GET /projects?scope=`

| Field | Type | Description |
|-------|------|-------------|
| `viewerRole` | string | `GroupLeader`, `CoLeader`, `Member` |
| `type` | string | `vacation`, `emergency`, `investment` |
| `displayStatus` | string | Chip label — see §3.3 |
| `raisedAmount` / `potAmount` | number | Amount card |
| **`memberCount`** | int | **Eligible voters** in last finalized vote — **not** `maxMembers` |
| **`lastVoteType`** | string | Same as `voting.voteType` |
| **`lastVoteOutcome`** | string | Same as `voting.outcome` — include **`NoVotes`** |
| **`successVoteApproved`** | bool | `true` if last finalized vote passed |
| `distributionStatus` | string | Optional — detail only |

> Investment **final closure no-votes** should stay **`ongoing` / `Funded`** — typically **not** on completed list. If mis-listed as completed with `lastVoteOutcome: NoVotes`, mobile opens **detail**, not outcome.

### 3.3 Canonical `displayStatus` labels

| Scenario | `displayStatus` | `projectStatus` |
|----------|-----------------|-----------------|
| Ongoing, contributions open | `On Going` | `ongoing` |
| Investment, stop-contrib passed (invest phase) | `Funded` | `ongoing` |
| Investment final closure **no votes** | `Funded` | **`ongoing`** |
| Completed, vacation / emergency approved | `Completed` or `Project Approved` | `completed` |
| Completed, investment final closure approved | `Completed` or `Distribution Complete` | `completed` |
| Vacation / emergency rejected (with votes) | `Project Not Approved` | `completed` / `cancelled` |
| Vacation / emergency / stop-contrib **no votes** | `Project Not Approved` | `completed` (vac/emer) or `ongoing` (stop-contrib) |
| Investment stop-contrib refund | `Refund in progress` → `Refund complete` | `completed` |
| Investment detail distributions | `Distributions In Progress` / `Distribution Complete` | `ongoing` or `completed` |

**Do NOT:**

- Leave vacation / emergency rejections as `On Going`
- Use `Refund in progress` / `Refund complete` for vacation or emergency
- Mark investment final-closure **no-votes** as `completed` — keep `ongoing` + `Funded`
- Omit `voting` tallies after finalize (send `0`/`0` for no-votes)

### 3.4 Finalize alignment

`POST /projects/{id}/closure-voting/finalize` returns `voteType`, `outcome`, tallies.

**Requirement:** The **same** values must appear on the next `GET /projects/{id}` and list rows.

---

## 4. JSON examples

### 4.1 Vacation — success vote **approved**

```json
{
  "projectStatus": "completed",
  "votingStatus": "done",
  "userRole": "leader",
  "project": {
    "type": "vacation",
    "displayStatus": "Completed",
    "potAmount": 9800.0,
    "lifecycleState": "completed"
  },
  "voting": {
    "voteType": "SuccessVote",
    "outcome": "Success",
    "isApproved": true,
    "isFinalized": true,
    "agreedCount": 5,
    "disagreedCount": 2,
    "pendingCount": 0,
    "eligibleVoterCount": 7
  }
}
```

### 4.2 Emergency — success vote **approved**

```json
{
  "projectStatus": "completed",
  "votingStatus": "done",
  "userRole": "co_leader",
  "project": {
    "type": "emergency",
    "displayStatus": "Project Approved",
    "potAmount": 9800.0
  },
  "voting": {
    "voteType": "SuccessVote",
    "outcome": "Success",
    "isApproved": true,
    "isFinalized": true,
    "agreedCount": 6,
    "disagreedCount": 1,
    "pendingCount": 0,
    "eligibleVoterCount": 7
  }
}
```

### 4.3 Vacation / Emergency — success vote **rejected** (majority disagreed)

```json
{
  "projectStatus": "completed",
  "votingStatus": "done",
  "userRole": "co_leader",
  "project": {
    "type": "emergency",
    "displayStatus": "Project Not Approved",
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

Vacation: identical except `"type": "vacation"`. **Not** `ongoing`. **No** refund-phase labels.

### 4.4 Vacation — **no votes** (deadline, zero participation)

```json
{
  "projectStatus": "completed",
  "votingStatus": "done",
  "userRole": "leader",
  "project": {
    "type": "vacation",
    "displayStatus": "Project Not Approved",
    "potAmount": 9800.0
  },
  "voting": {
    "voteType": "SuccessVote",
    "outcome": "NoVotes",
    "isApproved": false,
    "isFinalized": true,
    "agreedCount": 0,
    "disagreedCount": 0,
    "pendingCount": 0,
    "eligibleVoterCount": 7
  }
}
```

Mobile: **No One Voted** title, refund captions, **vote summary hidden**. Emergency: same shape with `"type": "emergency"`.

> Acceptable alternative: `"outcome": "Disputed"` with `agreedCount: 0`, `disagreedCount: 0`. Prefer explicit `"NoVotes"`.

### 4.5 Investment — stop-contributions **rejected** (keep contributing)

```json
{
  "projectStatus": "ongoing",
  "votingStatus": "done",
  "userRole": "leader",
  "canStopContributions": true,
  "project": {
    "type": "investment",
    "displayStatus": "On Going",
    "potAmount": 9800.0,
    "lifecycleState": "active"
  },
  "voting": {
    "voteType": "StopContributionsVote",
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

Mobile: **Vote Not Passed** (not Project Not Approved).

### 4.6 Investment — stop-contributions **no votes**

```json
{
  "projectStatus": "ongoing",
  "votingStatus": "done",
  "userRole": "member",
  "canStopContributions": true,
  "project": {
    "type": "investment",
    "displayStatus": "Project Not Approved",
    "potAmount": 9800.0
  },
  "voting": {
    "voteType": "StopContributionsVote",
    "outcome": "NoVotes",
    "isApproved": false,
    "isFinalized": true,
    "agreedCount": 0,
    "disagreedCount": 0,
    "pendingCount": 0,
    "eligibleVoterCount": 7
  }
}
```

Mobile: **No One Voted** (same as vacation no-votes).

### 4.7 Investment — stop-contributions **passed** (Start Investing)

**No outcome screen** — project stays **ongoing / Funded**; leader sees **Distribute Funds**, members see **Investment Returns** on project detail.

```json
{
  "projectStatus": "ongoing",
  "votingStatus": "done",
  "userRole": "leader",
  "canStopContributions": false,
  "project": {
    "type": "investment",
    "displayStatus": "Funded",
    "potAmount": 19800.0,
    "lifecycleState": "funded"
  },
  "voting": {
    "voteType": "StopContributionsVote",
    "outcome": "InvestmentStarted",
    "isApproved": true,
    "isFinalized": true,
    "agreedCount": 5,
    "disagreedCount": 2,
    "pendingCount": 0,
    "eligibleVoterCount": 7
  }
}
```

Acceptable alternative: `"outcome": "Success"` with `isApproved: true`. **Must** set `canStopContributions: false`, `displayStatus: Funded`, `lifecycleState: funded`. **Not** `completed` — that is for final closure (§4.9).

**Completed list row** (if shown on home / active lists, not completed):

```json
{
  "id": "…",
  "name": "Growth Fund",
  "type": "investment",
  "displayStatus": "Funded",
  "raisedAmount": 19800.0,
  "viewerRole": "GroupLeader",
  "memberCount": 7,
  "lastVoteType": "StopContributionsVote",
  "lastVoteOutcome": "InvestmentStarted",
  "successVoteApproved": true
}
```

### 4.8 Investment — stop-contributions **refund** (Refund Me passed)

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

Refund complete: same shape; `displayStatus: "Refund complete"`. Mobile keys off `voteType` + `outcome: Refund`, not `isApproved` alone.

### 4.9 Investment — final closure **approved** (votes cast)

```json
{
  "projectStatus": "completed",
  "votingStatus": "done",
  "userRole": "member",
  "canStopContributions": false,
  "project": {
    "type": "investment",
    "displayStatus": "Completed",
    "potAmount": 19800.0
  },
  "voting": {
    "voteType": "FinalClosureVote",
    "outcome": "InvestmentStarted",
    "isApproved": true,
    "isFinalized": true,
    "distributionStatus": "Complete",
    "agreedCount": 5,
    "disagreedCount": 2,
    "pendingCount": 0,
    "eligibleVoterCount": 7
  }
}
```

Mobile: **Project Successfully completed!** — **same copy for leader, co-leader, member**. `distributionStatus` ignored on outcome screen.

### 4.10 Investment — final closure **no votes** (mark successful, no participation)

**No outcome screen** — opens funded project detail with Distribute Funds / Investment Returns.

```json
{
  "projectStatus": "ongoing",
  "votingStatus": "done",
  "userRole": "leader",
  "canStopContributions": false,
  "project": {
    "type": "investment",
    "displayStatus": "Funded",
    "potAmount": 19800.0,
    "lifecycleState": "funded"
  },
  "voting": {
    "voteType": "FinalClosureVote",
    "outcome": "InvestmentStarted",
    "isApproved": true,
    "isFinalized": true,
    "agreedCount": 0,
    "disagreedCount": 0,
    "pendingCount": 0,
    "eligibleVoterCount": 7
  }
}
```

Acceptable alternative: `"outcome": "NoVotes"` with `isApproved: true`. **Must** keep `projectStatus: ongoing`, `displayStatus: Funded`, `lifecycleState: funded`.

### 4.11 Completed list rows

**Rejected stop-contrib:**

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

**Vacation no-votes:**

```json
{
  "id": "…",
  "name": "Beach Trip",
  "type": "vacation",
  "displayStatus": "Project Not Approved",
  "raisedAmount": 9800.0,
  "viewerRole": "Member",
  "memberCount": 7,
  "lastVoteType": "SuccessVote",
  "lastVoteOutcome": "NoVotes",
  "successVoteApproved": false
}
```

**Investment final closure approved:**

```json
{
  "id": "…",
  "name": "Growth Fund",
  "type": "investment",
  "displayStatus": "Completed",
  "raisedAmount": 19800.0,
  "viewerRole": "Member",
  "memberCount": 7,
  "lastVoteType": "FinalClosureVote",
  "lastVoteOutcome": "InvestmentStarted",
  "successVoteApproved": true
}
```

---

## 5. Backend QA checklist

- [ ] After finalize, `GET /projects/{id}` returns `voting.voteType`, `voting.outcome`, `voting.isApproved`, tallies (including `0`/`0`).
- [ ] `POST finalize` and next `GET` return **identical** vote envelope.
- [ ] Vacation approved: `outcome: Success`, `isApproved: true`, role-based copy per §2.1.
- [ ] Emergency approved: `outcome: Success`, `isApproved: true`, role-based copy per §2.2.
- [ ] Vacation / emergency rejected: `projectStatus` completed/cancelled, `displayStatus: Project Not Approved`, tallies > 0, **no** refund-phase labels.
- [ ] Vacation / emergency **no votes**: `outcome: NoVotes` (or zero tallies), `isApproved: false`, mobile shows **No One Voted** (§2.4).
- [ ] Investment stop-contrib failed: `canStopContributions: true`, `displayStatus: On Going`, tallies > 0.
- [ ] Investment stop-contrib **no votes**: `outcome: NoVotes`, zero tallies, **No One Voted** UI.
- [ ] Investment stop-contrib refund: `outcome: Refund`, `displayStatus` refund lifecycle.
- [ ] Investment stop-contrib passed (invest): `canStopContributions: false`, `displayStatus: Funded`, **no** outcome screen.
- [ ] Investment final closure approved: `outcome: InvestmentStarted`, unified success copy all roles.
- [ ] Investment final closure **no votes**: `isApproved: true`, `ongoing` + `Funded`, **no** outcome screen; Distribute / Returns on detail.
- [ ] List rows include `successVoteApproved`, `lastVoteType`, `lastVoteOutcome`, correct `memberCount` (eligible voters).
- [ ] `userRole` / `viewerRole` match caller membership.

### Common mistakes

| Mistake | Correct behavior |
|---------|------------------|
| Vacation / emergency rejected stays `On Going` | `completed`/`cancelled` + `Project Not Approved` |
| Vacation / emergency use `Refund in progress` | Refund labels **investment stop-contrib only** |
| No-votes sent as `Disputed` with non-zero tallies | Zero tallies or explicit `NoVotes` |
| No-votes uses majority-disagreed copy | Mobile distinguishes via zero tallies / `NoVotes` |
| Investment final-closure no-votes marked `completed` | Stay `ongoing` + `Funded` — detail UI only |
| `memberCount` = `maxMembers` on list | Use **eligible voter count** |
| Omit `voting` after project completes | Persist full envelope including tallies |
| Stop-contrib passed but still `canStopContributions: true` | Set `false` after vote passes |
| Stop-contrib invest passed marked `completed` | Stay `ongoing` + `Funded` until final closure |
| Outcome screen varies by `distributionStatus` | Final investment approved = one UI; distribution is detail-only |

---

## 6. Summary

| Question | Answer |
|----------|--------|
| Is this doc enough? | **Yes** — decision tree, UI matrix, fields, JSON, QA |
| Primary API | `GET /projects/{id}` |
| List APIs | `GET /projects/completed`, `GET /projects?scope=` |
| New `outcome` value | **`NoVotes`** — zero participation after deadline |
| No-votes vacation / emergency / stop-contrib | `isApproved: false`, **No One Voted** outcome screen |
| No-votes investment final closure | `isApproved: true`, `Funded` ongoing, **no** outcome screen |
| Investment final approved (with votes) | One screen all roles — no distribution phase on outcome |
| Vacation / emergency rejected | `Project Not Approved` — never refund-phase labels |
| Investment stop-contrib passed (invest) | `Funded` ongoing, `canStopContributions: false`, `outcome: InvestmentStarted` — see §4.7 |
| Investment refund phase | Only `StopContributionsVote` + `outcome: Refund` — see §4.8 |

**Mobile status (2026-07-09):** Parses `NoVotes`, zero-tally detection, no-votes copy, investment final-closure no-votes routes to detail. Falls back to `displayStatus` heuristics only when `voting` envelope is missing.
