# Week 11 — Voting Flow Audit & QA Handoff

**Date:** 2026-06-02  
**API:** `GET /projects/{id}` — `projectStatus`, `votingStatus`, `userRole`, `voting`, `canStopContributions`  
**Audience:** QA, backend, mobile — use before removing dev preview links.

---

## Executive summary

| Verdict | Detail |
|---------|--------|
| **Do not remove preview links yet** | Several production paths from the integration guide are missing or disabled. Previews currently mask gaps for leader monitor, outcome, and completed layouts. |
| **Data layer** | Week 11 fields parse correctly; entity getters largely match the guide. |
| **UI layer** | Voting **card** and status **banner** are built but **not shown** in production layouts. Member cast via **inline full-screen** works. Leader flows rely on **⋯ menu** (not the guide’s voting card). |

---

## Compliance matrix (guide vs app)

Legend: ✅ Implemented · ⚠️ Partial · ❌ Missing / wrong

### `projectStatus` — status banner (§4)

| Requirement | Status | Notes |
|-------------|--------|-------|
| Always show banner from `projectStatus` | ❌ | `ProjectDetailStatusBanner` exists but is **not mounted** in any detail layout. |
| Green / blue / red for ongoing / completed / cancelled | ✅ | Widget colors match guide when used. |
| Use `displayStatus` only for list pills | ✅ | `displayStatusLabel` separate from `projectBannerStatus`. |

### `votingStatus` — voting card (§5)

| Requirement | Status | Notes |
|-------------|--------|-------|
| Show card only when `projectStatus === ongoing` | ⚠️ | Logic in `ProjectDetailVotingCard` + getters; **`showsProjectDetailVotingCard` is hard-coded `false`**. |
| `not_started` — message + Start Voting (leader, co_leader) | ⚠️ | Card UI exists; **not rendered**. Co-leader has **no ⋯ menu** path to start vote. |
| `pending` — schedule, counts, View Votes + Close Voting (mod) | ❌ | Card disabled; Week 11 **`showsViewSuccessVotesAction` is false**; wallet CTAs hidden. |
| `pending` — member Cast Vote / Vote Submitted | ⚠️ | **Cast:** inline `ProjectDetailInlineCastVote` ✅. **Vote Submitted label:** only on card ❌. |
| `done` — result bars + Finalize (leader, `!isFinalized`) | ❌ | Card disabled; no other production Finalize entry on detail. |
| Hide card when completed / cancelled | ✅ | Would work if card re-enabled + `projectBannerStatus` check. |

### `userRole` — permissions (§6–7)

| Role | Start vote | View votes | Close vote | Finalize | Cast vote |
|------|------------|------------|------------|----------|-----------|
| **leader** | ⚠️ Menu only (Mark Successful / Stop Contributions), not card | ❌ Week 11 | ❌ | ❌ On detail | N/A |
| **co_leader** | ❌ No menu item; card off | ❌ | ❌ | ❌ (guide: leader only) ✅ | N/A |
| **member** | N/A | N/A | N/A | N/A | ✅ Inline when `pending` + `!hasVoted` |

**Preferred field:** `detailUserRole` from top-level `userRole` when Week 11 envelope present ✅

### API actions (§9)

| Action | Endpoint | Wired | Notes |
|--------|----------|-------|-------|
| Start Voting | `POST …/closure-voting/open` | ✅ | `VotingWindowScreen` + cubit; `voteType` from category/state. |
| Cast Vote | `POST …/closure-voting/vote` | ✅ | `ProjectDetailInlineCastVote` → `submitVoteUseCase`. |
| View Votes | `GET …/closure-voting/active` | ⚠️ | `LeaderViewSuccessVotesScreen`; hard to reach in Week 11. |
| Close / Finalize | `POST …/closure-voting/finalize` | ⚠️ | On voting card only (disabled); outcome navigation after finalize ✅. |

### Investment two-phase menu (§8 + `canStopContributions`)

| Phase | API | Stop Contributions | Mark as Successful |
|-------|-----|--------------------|--------------------|
| Contributions open | `canStopContributions: true` | ✅ ⋯ menu | Hidden ✅ |
| After stop-contrib done | `canStopContributions: false` | Hidden ✅ | ✅ ⋯ menu |
| Project completed | `projectStatus: completed` | Hidden | N/A — **Distribute Funds** on completed layout ✅ |

### After finalize — outcomes (§11)

| Outcome | Leader UI | Member UI |
|---------|-----------|-----------|
| Approved (`Success`, `InvestmentStarted`) | ✅ `SuccessVoteOutcomeScreen` after finalize | ⚠️ Home `userFlow` / completed list only |
| Rejected (`Refund`, `Disputed`) | ✅ Outcome screen | ⚠️ Same as above |
| Stop-contrib rejected variant | ✅ `stopContributionsRejected` copy | ⚠️ Same |

### Post-finalize project state (§10–11)

| Expected | App behavior |
|----------|--------------|
| `projectStatus` → completed / cancelled | Parsed ✅; completed layout on investment ✅ |
| `votingStatus` → `not_started`, `voting` null | Parsed ✅ |
| Card hidden when not ongoing | Card already hidden |

---

## What works today (production paths)

1. **Parse Week 11** — `projectStatus`, `votingStatus`, `userRole`, `voting`, `canStopContributions` on `GET /projects/{id}`.
2. **Member cast (pending)** — full-screen `ProjectDetailInlineCastVote` on vacation/emergency + investment detail.
3. **Leader start vote** — Mark Successful / Stop Contributions → voting window → `POST open` (group leader, investment menu gating).
4. **Leader finalize + outcome** — implemented on **voting card** (`_onFinalize` → outcome screen); card not shown.
5. **Synthetic active vote** — built from `voting` for legacy monitor when `votingIsInProgress`.
6. **Skip redundant `GET active`** when detail already has voting payload.
7. **Tests** — `project_detail_week11_voting_test.dart`, `project_detail_entity_permissions_test.dart`.

---

## Critical gaps (fix before removing previews)

### P0 — Voting card disabled

```dart
// project_detail_entity.dart
bool get showsProjectDetailVotingCard => false;
```

**Impact:** Hides Start Voting, View Votes, Close Voting, Finalize, schedule/counts, and **Vote Submitted** for members per guide §5.

**Fix:** Re-enable when `projectBannerStatus == ongoing` and Week 11 envelope present (original spec). Keep inline member cast **or** card Cast button — product choice (guide shows card button; app uses inline).

### P0 — Status banner not rendered

`ProjectDetailStatusBanner` is not used in `ProjectDetailMemberLayout`, `ProjectDetailModeratorScrollContent`, or `InvestmentProjectDetailScreen`.

**Fix:** Add banner at top of scroll content when `showsProjectDetailStatusBanner`.

### P0 — Leader / co-leader cannot monitor vote (Week 11)

- `showsViewSuccessVotesAction` requires `!hasWeek11VotingPayload` (legacy only).
- Voting card (View Votes) disabled.
- `hidesWalletActionsForVoting` hides Contribute/Borrow but does not add View Votes.

**Fix:** Show View Votes when `canViewVotesOnDetail` (leader + co_leader, `pending`/`done`).

### P0 — No Finalize on detail (Week 11)

`canFinalizeVotingOnDetail` is correct (leader, `done`, `!isFinalized`) but only wired to disabled card.

**Fix:** Surface Finalize on re-enabled card or leader action when `votingStatus == done`.

### P1 — Co-leader cannot start vote

Guide: co_leader same as leader for Start Voting. Co-leader ⋯ menu has no Mark Successful / Stop Contributions.

**Fix:** Add voting start to co-leader menu or rely on voting card Start Voting when re-enabled.

### P1 — Member “Vote Submitted” after cast

After vote, member returns to normal scroll; label only exists on voting card.

**Fix:** Show submitted chip/banner on member scroll when `showsMemberVoteSubmittedLabel`.

### P1 — Member outcome after finalize

No automatic navigation to outcome screen from project detail; depends on home card `userFlow`.

**Fix:** Backend push notification + `userFlow`, or poll detail after finalize event.

### P2 — Dev preview links still in production UI

`showsMemberSuccessVoteDevPreviews => true` always — preview links visible to all members.

**Fix:** Remove after P0/P1 resolved, or gate with `kDebugMode`.

---

## Preview links — keep or remove?

| Preview | Masks which gap? | Remove when |
|---------|------------------|-------------|
| Preview cast vote | Member cast without live vote | Inline cast verified in QA |
| Preview view success votes | Leader monitor | View Votes production path works |
| Preview outcome approved/rejected | Finalize outcome | Leader finalize + member outcome path works |
| Preview completed investment | Completed layout | `projectStatus: completed` QA passed |
| Preview stop-contrib rejected | Rare outcome copy | Finalize with failed stop-contrib vote tested |

**Recommendation:** Keep previews in **debug builds only** until P0 items closed; then remove from release.

---

## QA scenarios (from integration guide §13)

Run on **vacation**, **emergency**, and **investment** with three accounts (leader, co_leader, member).

### Scenario A — No vote yet

| Field | Value |
|-------|-------|
| projectStatus | ongoing |
| votingStatus | not_started |
| userRole | leader |

**Expected:** Green banner, “Voting hasn’t started”, **Start Voting**.  
**Current:** No banner; no card; leader may use ⋯ Mark Successful / Stop Contributions (investment) instead.

### Scenario B — Vote pending, member not voted

**Expected:** Schedule, counts, member **Cast Vote** (or inline cast).  
**Current:** Member inline cast ✅; no card counts for leader.

### Scenario C — Deadline done, leader finalize

**Expected:** Result summary, **Finalize Decision**.  
**Current:** ❌ No visible Finalize on detail.

### Scenario D — Project completed

**Expected:** Blue banner only, no voting card.  
**Current:** No banner; investment shows Distribute Funds ✅.

### Investment-specific

| Step | canStopContributions | Expected UI |
|------|----------------------|-------------|
| 1 | true | Stop Contributions only |
| 2 | false | Mark as Successful only |
| 3 | finalize stop-contrib → funded | ongoing, funded |
| 4 | finalize final closure | completed, Distribute Funds |

---

## Key files reference

| Area | Path |
|------|------|
| Entity getters | `lib/features/project_detail/domain/entities/project_detail_entity.dart` |
| API parse | `lib/features/project_detail/data/models/project_detail_response_model.dart` |
| Voting card | `lib/features/project_detail/presentation/widgets/project_detail_voting_card.dart` |
| Card wrapper | `lib/features/project_detail/presentation/widgets/project_detail_voting_sections.dart` |
| Status banner | `lib/features/project_detail/presentation/widgets/project_detail_status_banner.dart` |
| Member inline cast | `lib/features/project_detail/presentation/widgets/project_detail_inline_cast_vote.dart` |
| Member layout | `lib/features/project_detail/presentation/widgets/project_detail_member_layout.dart` |
| Moderator layout | `lib/features/project_detail/presentation/widgets/project_detail_moderator_scroll_content.dart` |
| Investment detail | `lib/user/features/project_detail/presentation/pages/investment_project_detail_screen.dart` |
| Preview links | `project_detail_cast_vote_dev_previews.dart`, `project_detail_vote_outcome_dev_previews.dart` |
| Outcome mapper | `lib/features/project_detail/presentation/mappers/closure_vote_ui_mappers.dart` |
| Tests | `test/features/project_detail/project_detail_week11_voting_test.dart` |

---

## Remediation backlog (suggested order)

1. Mount `ProjectDetailStatusBanner` on all detail layouts (ongoing/completed/cancelled).
2. Re-enable `showsProjectDetailVotingCard` for `projectBannerStatus == ongoing` + Week 11 envelope.
3. Wire **View Votes** for Week 11 when `canViewVotesOnDetail`.
4. Wire **Finalize** when `canFinalizeVotingOnDetail`.
5. Member **Vote Submitted** on scroll when card not used for cast.
6. Co-leader **Start Voting** (menu or card).
7. Member **outcome** after finalize (API `userFlow` or in-app).
8. Gate or remove preview links; run QA matrix above.
9. Update `feature_overview.md` and remove stale “card disabled” notes.

---

## Automated tests to run

```bash
flutter test test/features/project_detail/project_detail_week11_voting_test.dart
flutter test test/features/project_detail/project_detail_entity_permissions_test.dart
```

Add widget tests for banner + card visibility per `projectStatus` / `votingStatus` / `userRole` when UI is re-enabled.

---

## Related docs

- `DOCS/week_11_project_detail_voting_plan.md` — original implementation plan
- `DOCS/week_10_closure_voting_integration_plan.md` — closure API & vote types
- `lib/features/project_detail/feature_overview.md` — feature entry point
