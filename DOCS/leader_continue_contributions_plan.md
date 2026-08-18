# Leader Continue Contribution / Cancel Vote — audit + app plan

**Status:** Plan only — not implemented in the app yet.  
**Related backend spec (share this with backend):** [`backend_handoff_cancel_closure_vote.md`](backend_handoff_cancel_closure_vote.md)

---

## 1. What exists today (audit)

### 1.1 Vote types the leader can start

Group leader (and co-leader, via the same menus where gated) starts a **closure vote** from project detail ⋯ menu:

| Leader action | Category | API `voteType` | After start |
|---------------|----------|----------------|-------------|
| Mark as Successful | Vacation / Emergency | `SuccessVote` | Members vote to release / close |
| Stop contributions | Investment (contribution phase) | `StopContributionsVote` | Members vote to stop contributing / start investing |
| Mark as Successful | Investment (already **Funded**) | `FinalClosureVote` | Members confirm ROI / close |

**Start flow (all three):**

```text
Detail ⋯ menu
  → Mark successful / Stop contributions intro screen
  → Voting window (enter days)
  → POST /projects/{id}/closure-voting/open
      { votingWindowDays, voteType }
  → reload GET /projects/{id}
  → “Voting started” success
  → Back to project detail
```

Code: `VotingWindowCubit` → `OpenClosureVotingUseCase` / `OpenStopContributionsVotingUseCase`.  
Route: `/leader/view-success-votes` after the vote is open.

### 1.2 What the **group leader** sees while a vote is open

Group leader **does not vote**. They **monitor**.

**Project detail**

- Contribute / Borrow **hidden**.
- Edit project / Cancel project **locked** (`canEditProject` / `canCancelProject` false while the vote window is open).
- Overflow ⋯ **still shown** for group leader (hidden only for member / co-leader).
- Wallet row becomes a single CTA:
  - Vacation / emergency / final closure → **View Success Votes**
  - Investment stop-contributions → **View Contribution Success Vote**
- That CTA opens the leader monitor screen (`LeaderViewSuccessVotesScreen`).

**Leader voting screen (monitor)** currently shows:

1. Countdown to deadline  
2. Tally cards: Agreed / Disagreed / Not yet voted  
3. Majority banner: `required of total members must Agree…`  
   - Majority math today: **eligible voters** (members + co-leader, **excluding group leader**), `floor(total/2)+1`  
   - **Not** `totalJoinedMember`  
4. Per-member list (`voting.memberVotes[]`)

**There is no Continue contribution button and no Cancel vote API.**  
`AppStrings.leaderSuccessVoteFinalizeButton` exists but is unused. The app **does not** call `POST …/closure-voting/finalize` — backend cron finalizes after the deadline.

### 1.3 What members / co-leaders see

- Co-leader and member: inline Yes/No on project detail (`POST …/closure-voting/vote`).
- Overflow menu hidden while vote is in progress.
- After they vote: post-vote inline UI (tallies), not the leader monitor.
- After backend finalize: full-screen outcome (approved / not approved / no one voted / refund), per `DOCS/outcome.md`.

### 1.4 After the vote (no cancel)

- Window ends → backend auto-finalize.
- Project leaves contributing (or stays funded / refunds) based on `voteType` + `outcome`.
- Leader **cannot** put the group back into the pre-vote contribute flow unless the vote **fails** in a way that already maps to “keep contributing” (investment stop-contrib **rejected**).

### 1.5 Gaps vs this request

| Need | Today |
|------|--------|
| Continue contribution while vote is open | **Missing** |
| Cancel the open vote so Contribute/Borrow return | **Missing** (`POST cancel` does not exist) |
| Hide Continue contribution at 50% of `totalJoinedMember` | **Missing** (monitor uses eligible-voter majority, not this gate) |
| `totalJoinedMember` on detail | Parsed for Total Members UI; **not used for voting** |

---

## 2. Product rule (agreed for this feature)

**Group leader only** can cancel an **open** vote and restore the project to the same state it had **immediately before** `POST …/open`.

UX name: **Continue contribution** (or **Cancel vote** on investment final-closure — contributions already closed).

**Do not show the button (and reject the API) when 50% of `totalJoinedMember` have already voted.**

```text
votesCast = agreedCount + disagreedCount
hide / reject when: votesCast * 2 >= totalJoinedMember
```

Exactly 50% counts as “done” → hide.

| `totalJoinedMember` | votes already cast | Show Continue contribution? |
|---------------------|--------------------|-----------------------------|
| 4 | 1 | Yes |
| 4 | 2 | **No** (50%) |
| 5 | 2 | Yes (40%) |
| 5 | 3 | **No** (60%) |
| 0 / null | any | **No** |

`totalJoinedMember` includes the group leader. The leader still does not vote. That is intentional: the gate is “half the joined roster has spoken,” not “half of eligible voters.”

This gate is **separate** from majority-to-pass (`floor(eligible/2)+1` Agree). A project can still be below majority-Agree and already past 50% participation.

Also hide / reject when:

- Viewer is not **GroupLeader**
- Vote is not `votingStatus: pending` (deadline passed / finalized)
- No open vote

---

## 3. How the app will handle it (after backend ships)

### 3.1 Load

Keep driving UI from **`GET /projects/{id}`**.

Read:

- `project.totalJoinedMember`
- `voting.agreedCount`, `voting.disagreedCount`, `votingStatus`, `isFinalized`, `voteType`
- **`voting.canContinueContributions`** (backend source of truth — app does not invent the 50% rule in isolation)

App may **also** compute the same formula locally as a fallback if the flag is omitted, but **POST cancel must still be enforced on the server**.

### 3.2 Leader monitor screen

On `LeaderViewSuccessVotesScreen`, pinned footer (group leader only):

- If `canContinueContributions == true` → **Continue contribution** (stop-contrib / success vote) or **Cancel vote** (final closure).
- If false → no button (do not show a disabled 0-state CTA).

Tap:

1. Confirm dialog (`AppActionDialog.showAsync`).
2. `POST /projects/{id}/closure-voting/cancel`.
3. On success: `reloadDetailAndWait` → pop monitor → project detail already in pre-vote state.
4. On 409 (50% reached): toast mapped message; reload monitor; button gone.
5. Footer `AppButton.isLoading` while POST + reload run.

### 3.3 After successful cancel (detail + home)

Expect from next `GET /projects/{id}`:

- `votingStatus: not_started`
- `voting: null`
- `displayStatus: On Going` (or previous Funded for final-closure cancel)
- Contribute / Borrow / Mark successful / Stop contributions **as before the vote**
- Home/Discover cards no longer show Closure Voting

App work:

- Parse `canContinueContributions` on the voting entity.
- Wire cancel use case → repository → `ApiConstants` path.
- Do **not** call cancel from co-leader or member UI.

### 3.4 Out of scope for this feature

- Changing majority-to-pass math (still eligible voters).
- Letting the leader vote.
- App-called finalize (cron stays).
- Using `memberCount` for this gate (`memberCount` remains eligible voters / vote-outcome only).

---

## 4. Implementation order (app, after backend)

1. Add `ApiConstants.projectClosureVotingCancel` + remote DS / use case / DI.
2. Parse `voting.canContinueContributions` + keep using `totalJoinedMember`.
3. Leader monitor footer + confirm dialog + error toast.
4. Tests: hide at 50%; show below; 409 handling; detail returns to contribute CTAs after mock cancel+reload.
5. Update `feature_overview.md` + `DOCS/qa/api_screen_sync_matrix.md` in the same PR.

Do not implement until backend accepts [`backend_handoff_cancel_closure_vote.md`](backend_handoff_cancel_closure_vote.md).
