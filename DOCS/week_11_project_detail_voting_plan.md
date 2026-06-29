# Week 11 — Project Detail Voting Card Integration

**API:** `GET /projects/{id}` returns `projectStatus`, `votingStatus`, `userRole`, `voting`  
**Goal:** Inline voting on project detail; no member navigation to `/user/success-vote` in production.

## Phases

| Phase | Scope | Status |
|-------|--------|--------|
| 1 | Domain enums + `ProjectVotingSummaryEntity`; parse Week 11 fields in `ProjectDetailResponseModel` | Done |
| 2 | `ProjectDetailEntity` getters; synthetic `ActiveClosureVoteEntity` for legacy View Votes screen; bloc skips redundant `GET active` when detail has voting | Done |
| 3 | `ProjectDetailStatusBanner`, `ProjectDetailVotingCard`, `AppStrings` | Done |
| 4 | Member inline cast (`ProjectDetailInlineCastVote`); integrate into member / moderator / investment layouts | Done |
| 5 | Tests + `feature_overview` note | Done |

## UI rules (from API guide)

- **Banner:** always from `projectStatus` (green / blue / red).
- **Voting card:** only when `projectStatus === ongoing`.
- **`not_started`:** message + Start Voting (leader + co-leader).
- **`pending`:** schedule, counts; leader/co-leader → View Votes + Close Voting; member → inline cast UI or Vote Submitted.
- **`done`:** result bars + Finalize Decision (leader only).

## Audit status (2026-06-02)

**See [week_11_voting_flow_audit_handoff.md](./week_11_voting_flow_audit_handoff.md)** for full QA matrix.

| Item | Status |
|------|--------|
| Week 11 API parse + entity getters | Done |
| Member inline cast (`pending`) | Done |
| `canStopContributions` menu gating (investment) | Done |
| Status banner on screen | **Not mounted** |
| Voting card on screen | **Disabled** (`showsProjectDetailVotingCard => false`) |
| Leader View Votes / Finalize (Week 11) | **Gap** |
| Co-leader Start Voting | **Gap** |
| Member Vote Submitted label | **Gap** (card only) |
| Remove dev preview links | **Blocked** until audit gaps closed |

## Performance & safety

- Week 11 UI is **gated** on `hasWeek11ProjectDetailEnvelope` — legacy `GET /projects/{id}` responses are unchanged (no banner, no card, no wallet swap).
- Skips redundant `GET …/closure-voting/active` when the detail payload already includes voting.
- Synthetic `ActiveClosureVoteEntity` is built only when `votingStatus` is `pending` or `done`.
- `ProjectDetailVotingSections` returns `SizedBox.shrink()` when there is nothing to show.
- `ProjectDetailInlineCastVote` caches cast UI data; reload is delegated to `ProjectDetailBloc` (single source of truth).
- Voting card uses a `ValueKey` on vote state so local submit loading resets after refresh.

- Dev preview links (`ProjectDetailCastVoteDevPreviews`, outcome previews).
- `/user/success-vote` route for previews and deep links.
- `GET …/closure-voting/active` for **View Votes** monitor screen.
- Leader voting window flow (`POST …/open`).

## Key files

- `project_detail_voting_entities.dart`
- `project_detail_response_model.dart`
- `project_detail_voting_card.dart`
- `project_detail_inline_cast_vote.dart`
- `project_detail_member_layout.dart`
