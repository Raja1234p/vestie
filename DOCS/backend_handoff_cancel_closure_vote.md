# Backend handoff — Cancel open closure vote (Continue contribution)

**Audience:** Vestie backend team  
**From:** Mobile (Flutter)  
**Date:** 2026-08-18  
**Status:** Deployed — `POST /api/v1/projects/{projectId}/closure-voting/cancel` matches this contract.

This is an **additive** contract. Existing open / vote / finalize behavior must stay the same.

---

## 1. Why

Group leader can start a vote (Mark successful / Stop contributions / Final closure). Today the vote **cannot be undone**. If they started too early, the group is stuck until the window ends and cron finalizes.

Product:

1. Group leader may **cancel the open vote** and restore the project to the **exact lifecycle it had before `POST …/open`** (contribute / borrow / menus again).
2. **Do not allow cancel** once **50% of `totalJoinedMember` have cast a vote**.
3. Mobile will label this **Continue contribution** (or **Cancel vote** on investment final-closure).

---

## 2. Existing APIs (do not change)

| Method | Path | Who | Purpose |
|--------|------|-----|---------|
| `POST` | `/api/v1/projects/{projectId}/closure-voting/open` | Group leader / co-leader | Start vote |
| `POST` | `/api/v1/projects/{projectId}/closure-voting/vote` | Member / co-leader | Cast Yes/No |
| `POST` | `/api/v1/projects/{projectId}/closure-voting/finalize` | Cron (mobile does **not** call) | Close window, persist outcome |
| `GET` | `/api/v1/projects/{projectId}` | All roles | Detail + `voting` envelope |

Group leader **does not** appear in `voting.memberVotes[]` and does **not** cast on success / stop-contrib votes. Keep that.

`GET /projects/{id}` **must include** `project.totalJoinedMember` (same field as list APIs). Mobile already reads it for Total Members.

---

## 3. New write API — **MUST IMPLEMENT**

### `POST /api/v1/projects/{projectId}/closure-voting/cancel`

**Auth:** Bearer token  
**Who:** **GroupLeader only** (not CoLeader, not Member)  
**When:** there is an **open** vote (`votingStatus == pending`, `voting.isFinalized == false`, deadline **not** passed)

**Request body:** empty `{}` or omit body.

```
POST /api/v1/projects/{projectId}/closure-voting/cancel
Authorization: Bearer <token>
Accept: application/json
Content-Type: application/json
```

### 3.1 Success `200`

Vote discarded. Project restored to **pre-open** state.

**Required side effects:**

| Area | After cancel |
|------|----------------|
| Open vote | Deleted / closed as **Cancelled** — not finalized with an outcome |
| `votingStatus` | `not_started` |
| `voting` on next GET | **`null` / omitted** (do not leave pending tallies) |
| Cast votes | Discarded (do not keep agreed/disagreed for a later vote) |
| Lifecycle | Same as immediately **before** this vote was opened |
| `displayStatus` | Vacation/emergency / stop-contrib: **`On Going`**. Investment **final closure** cancel: previous **`Funded`** (contributions stay closed) |
| `canStopContributions` | Unchanged vs pre-open (typically `true` again after cancelling a stop-contrib vote) |
| Contribute / borrow | Allowed again as before the vote |
| Leader menus | Mark successful / Stop contributions available again (same gates as before) |
| List APIs | Cards must **not** show Closure Voting; no leftover `lastVoteType` / `lastVoteOutcome` from the **cancelled** vote |

**Response (minimal is fine):**

```json
{
  "cancelled": true,
  "projectId": "25f7fe65-5fd8-4b00-991c-2c45f16001d5",
  "votingStatus": "not_started"
}
```

Mobile will always **reload `GET /projects/{id}`** after `200`. The GET is the source of truth.

### 3.2 Error contracts (must be consistent)

| HTTP | When | Body `code` (suggested) | User-facing intent |
|------|------|-------------------------|--------------------|
| `403` | Caller is not GroupLeader | `Forbidden` | Not allowed |
| `404` | No **open** vote | `NoOpenVote` | Nothing to cancel |
| `409` | 50% participation already reached | `VoteParticipationThresholdReached` | Too late to continue contributions |
| `409` | Deadline passed / waiting finalize | `VoteWindowClosed` | Too late |
| `409` | Already finalized | `VoteAlreadyFinalized` | Too late |

Example `409`:

```json
{
  "code": "VoteParticipationThresholdReached",
  "message": "Continue contribution is no longer available because at least 50% of joined members have voted."
}
```

Mobile will toast the mapped message and reload detail.

---

## 4. 50% gate (server must enforce — not UI-only)

```text
votesCast = agreedCount + disagreedCount
total     = project.totalJoinedMember

ALLOW cancel  when: total > 0 AND votesCast * 2 < total
REJECT cancel when: total <= 0 OR votesCast * 2 >= total
```

Exactly **50% hides / rejects**. Pending (not voted) does **not** count as cast.

| Joined (`totalJoinedMember`) | Agreed+Disagreed | Allow cancel? |
|------------------------------|------------------|---------------|
| 4 | 1 | Yes |
| 4 | 2 | **No** |
| 5 | 2 | Yes |
| 5 | 3 | **No** |
| `null` / `0` | any | **No** |

**Denominator is `totalJoinedMember` (joined roster), not `memberCount` / `eligibleVoterCount`.**  
`memberCount` stays **eligible voters** for majority-to-pass and vote-outcome UI. Do not mix the two.

Group leader is included in `totalJoinedMember` but still does not vote. Example: leader + 1 member → `totalJoinedMember = 2`. One member vote → 50% → cancel **blocked**.

---

## 5. GET `/projects/{id}` — add these fields while a vote is open

Keep the existing `voting` object. Add:

| Field | Type | Required when vote open | Description |
|-------|------|-------------------------|-------------|
| `project.totalJoinedMember` | int | Yes (always on `project`) | Joined roster. Same as list API. |
| `voting.canContinueContributions` | bool | **Yes** | `true` only if **this caller** may cancel (GroupLeader + open window + below 50% gate). Co-leader/member: always `false`. |
| `voting.votesCast` | int | Recommended | `agreedCount + disagreedCount` (convenience) |

Mobile will **hide** Continue contribution unless `canContinueContributions === true`.  
Backend must still **reject** `POST cancel` if the flag would be false (race: last vote lands between GET and POST).

### 5.1 Example — leader, vote open, button **shown** (1 of 4 joined have voted)

```json
{
  "project": {
    "id": "25f7fe65-5fd8-4b00-991c-2c45f16001d5",
    "type": "vacation",
    "displayStatus": "Closure Voting",
    "viewerRole": "GroupLeader",
    "totalJoinedMember": 4,
    "memberCount": 3
  },
  "votingStatus": "pending",
  "userRole": "leader",
  "voting": {
    "startedAtUtc": "2026-08-18T16:10:00Z",
    "deadlineAtUtc": "2026-08-21T16:10:00Z",
    "agreedCount": 1,
    "disagreedCount": 0,
    "pendingCount": 2,
    "hasVoted": false,
    "isFinalized": false,
    "voteType": "SuccessVote",
    "eligibleVoterCount": 3,
    "canContinueContributions": true,
    "votesCast": 1,
    "memberVotes": []
  }
}
```

`memberCount` / `eligibleVoterCount` = 3 (voters, no leader).  
`totalJoinedMember` = 4 (roster). Gate uses **4**, not 3.

### 5.2 Example — same vote after 2 casts → button **hidden**

```json
{
  "project": {
    "totalJoinedMember": 4,
    "viewerRole": "GroupLeader"
  },
  "votingStatus": "pending",
  "voting": {
    "agreedCount": 1,
    "disagreedCount": 1,
    "pendingCount": 1,
    "isFinalized": false,
    "canContinueContributions": false,
    "votesCast": 2
  }
}
```

`POST cancel` must return **409** `VoteParticipationThresholdReached`.

### 5.3 Example — after successful cancel

```json
{
  "project": {
    "id": "25f7fe65-5fd8-4b00-991c-2c45f16001d5",
    "type": "vacation",
    "state": "active",
    "lifecycleState": "active",
    "displayStatus": "On Going",
    "viewerRole": "GroupLeader",
    "totalJoinedMember": 4
  },
  "votingStatus": "not_started",
  "userRole": "leader"
}
```

No `voting` object. Contribute / Borrow / Mark successful work again.

---

## 6. Restore-by-vote-type (must match “same flow as before voting”)

| Cancelled `voteType` | Restore to |
|----------------------|------------|
| `SuccessVote` (vacation / emergency) | Ongoing group: contribute + borrow (if enabled), Mark successful available |
| `StopContributionsVote` (investment) | Contribution phase: contribute, `canStopContributions: true`, **not** Funded |
| `FinalClosureVote` (investment already funded) | Stay **Funded**; contributions stay stopped; Mark successful available again. This is **not** reopening contributions. |

A later **new** `POST …/open` starts a **fresh** vote (new id, all `waiting`).

---

## 7. What not to do

- Do **not** treat cancel as finalize with `Disputed` / `NoVotes` — that would open outcome screens.
- Do **not** use `memberCount` for the 50% gate.
- Do **not** allow CoLeader to cancel.
- Do **not** allow cancel after deadline or after cron finalize.
- Do **not** keep `lastVoteOutcome` from a cancelled in-progress vote on list payloads.

---

## 8. Backend checklist

- [ ] `POST …/closure-voting/cancel` implemented, GroupLeader only
- [ ] 50% rule: `votesCast * 2 >= totalJoinedMember` → 409
- [ ] Race-safe: evaluate the gate **inside** the cancel transaction
- [ ] Next `GET /projects/{id}` has `votingStatus: not_started` and no `voting`
- [ ] `project.totalJoinedMember` always present on detail + list
- [ ] `voting.canContinueContributions` accurate per caller while vote is pending
- [ ] List cards (`GET /projects?scope=mine`) no longer show Closure Voting after cancel
- [ ] Members can contribute again (vacation/emergency / investment stop-contrib cancel)
- [ ] Optional: notify members that the leader cancelled the vote

---

## 9. Mobile follow-up (after this ships)

Flutter will:

1. Show **Continue contribution** on the Group Leader monitor screen only when `canContinueContributions` is true.
2. Confirm → `POST cancel` → reload detail → return to contribute flow.
3. Hide the button at 50% / non-leader / closed window.

No further backend work is required for this contract unless the 50% GET flag or restore side effects drift.
