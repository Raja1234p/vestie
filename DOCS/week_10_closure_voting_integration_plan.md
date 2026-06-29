# Week 10 — Project Closure & Returns · Mobile integration plan

**API reference date:** 21 June 2026  
**Scope:** Project closure / success voting (mark successful, stop contributions, final closure) + investment returns/distribute.  
**Constraints:** Keep all existing navigation flows and **dev preview links**; add production API paths alongside previews.

---

## 1. Existing client vs Week 10 API

| Area | Current client | Week 10 spec | Action |
|------|----------------|--------------|--------|
| **Open vote** | `POST …/closure-voting/open` with `successVoteWindowHours` | Same path, body `{ votingWindowDays, voteType }` | **Align** |
| **Stop contributions open** | `POST …/contributions/stop-voting/open` with `stopContributionsVoteWindowHours` | Unified `closure-voting/open` + `voteType: StopContributionsVote` | **Replace** |
| **Cast vote** | `{ decision: Approve \| Reject }` | `{ vote: Yes \| No }` | **Align** |
| **Get active vote** | Missing | `GET …/closure-voting/active` | **Add** |
| **Finalize** | `POST …/finalize` (void) | Same path, returns outcome + `projectStatus` | **Extend** |
| **Extend vote** | `POST …/extend` | Not in Week 10 | **Keep** (unused UI; no removal) |
| **Cancel project** | `POST …/cancel` (void) | Returns refund summary | **Extend** (Phase 7) |
| **Investment distribute** | Mock UI | `preview` + `distribute` | Phase 8 |
| **My returns / GL history** | Mock UI | `my-returns` + `distributions` | Phase 8 |
| **`hasActiveSuccessVote`** | Entity field, never parsed | Derive from `GET active` (404 = false) or project flag if added | Phase 3 |

### Vote type mapping (leader voting window)

| UI flow | Category | `voteType` |
|---------|----------|------------|
| Mark successful | Vacation / Emergency | `SuccessVote` |
| Mark successful | Investment (funded) | `FinalClosureVote` |
| Stop contributions | Investment (active) | `StopContributionsVote` |

### UI label → API

| Screen | API |
|--------|-----|
| Agree / Confirm | `"Yes"` |
| Disagree / Dispute | `"No"` |

---

## 2. Screens × roles × phases

| Screen | Route | Leader | Co-leader | Member | Phase |
|--------|-------|:------:|:---------:|:------:|-------|
| Mark successful intro | `/project/mark-successful` | ✓ | — | — | 3 (wire reload) |
| Stop contributions intro | `/project/stop-contributions` | ✓ | — | — | 3 |
| Voting window | `/project/voting-window` | ✓ | — | — | 3 |
| Leader vote started | `/project/leader-vote-started` | ✓ | — | — | 3 (no API) |
| View success votes | `/project/leader-view-success-votes` | ✓ | ✓* | — | 5 |
| Cast vote | `/user/success-vote` | — | ✓ | ✓ | 4 |
| Vote outcome | `/user/vote-outcome` | preview | preview | preview | 6 |
| Distribute funds | `/project/investment/distribute-funds` | ✓ | — | — | 8 |
| My investment returns | `/user/investment/my-returns` | — | ✓ | ✓ | 8 |

\* Vacation / emergency when `hasActiveSuccessVote`.

**Preview links:** `ProjectDetailCastVoteDevPreviews`, `ProjectDetailVoteOutcomeDevPreviews` — **never removed**; production CTAs added in parallel when vote is active.

---

## 3. Implementation phases

### Phase 1 — Data layer & Week 10 contract (this PR)
- Domain entities: `ClosureVoteType`, `ClosureVoteValue`, `ActiveClosureVoteEntity`, open/cast/finalize result entities
- `closure_voting_response_model.dart` + unit tests
- `ApiConstants` closure-voting + investment paths
- Align `open` / `cast` wire format; unify stop-contributions into `open`
- `GET …/closure-voting/active` + `GetActiveClosureVoteUseCase`
- No screen wiring yet

### Phase 2 — Repository consolidation
- `ClosureVotingRepository` — single source for open / cast / active / finalize
- `CastClosureVoteUseCase` delegates to `SubmitVoteUseCase`
- Typed returns: `OpenClosureVoteEntity`, `CastClosureVoteResultEntity`, `FinalizeClosureVoteResultEntity`
- `ClosureVotingFailureMapper` for 403 GL / 400 deadline / no open vote
- **Done**

### Phase 3 — Leader open vote + project detail flag
- `VotingWindowRouteArgs` + cubit: pass category → resolve `voteType`
- After open: reload project detail; set `hasActiveSuccessVote` via active-vote probe
- Production CTA: **View Success Votes** / **Cast Vote** when active (keep previews)
- **Done**

### Phase 4 — Cast vote screen (member / co-leader)
- `SuccessVoteCastCubit`: load `GET active` on mount when `projectId` set
- Preview mode: route args without API load (existing mock tallies)
- After cast: refresh tallies from response; reload project detail
- GL cannot vote (`callerIsGL` → hide actions)
- **Done**

### Phase 5 — Leader / co-leader monitor
- `LeaderViewSuccessVotesCubit`: load `GET active` on mount; pull-to-refresh
- Member rows: merge project `members` + pattern until API adds per-member votes (**documented gap**)
- Optional: manual finalize when deadline passed (GL only)
- Preview mode via `isPreview: true` (dev preview links unchanged)
- **Done**

### Phase 6 — Vote outcome screen
- Navigate from finalize response / push / project status change
- Map `outcome` → `SuccessVoteOutcomeVariant` (Success, Refund, InvestmentStarted, Disputed)
- Preview factories unchanged
- **Done** (finalize → outcome wired for GL monitor; push/status hooks deferred)

### Phase 7 — Cancel project response
- Parse cancel response; success screen with refund counts
- **Done**

### Phase 8 — Investment returns & distribute
- `POST distribute/preview`, `POST distribute`, `GET my-returns`, `GET distributions`
- Replace mock `InvestmentReturnsUiData` / `InvestmentDistributionUiData` in production paths only
- **Done**

---

## 4. Architecture rules (from `.cursor/rules`)

- Parse API enums in **data models**; presentation uses entity getters (`isYes`, `hasAgreed`)
- `ApiConstants` only for paths; `AppStrings` for UI
- Cubit/Bloc for load + submit; shimmer + `AppErrorView` on load fail; `AppToast` on action fail
- Reload project detail **before** success UI after POST
- Update `feature_overview.md` + `DOCS/qa/api_screen_sync_matrix.md` per phase

---

## 5. Known API gaps

| UI need | Week 10 `GET active` | Workaround |
|---------|----------------------|------------|
| Per-member vote status (leader list) | Not in response | Show tallies only; member names from project roster with “waiting” until backend extends payload |
| `hasActiveSuccessVote` on project detail | Not documented | Probe `GET active` after detail load (404 = false) |

---

## 6. Test plan (per phase)

1. Model JSON parsing (open, active, cast, finalize)
2. `voteType` resolution from `LeaderVotingFlowKind` + category
3. Cubit/bloc: load success, 404 → no active vote, cast updates tallies
4. Widget smoke: preview links still visible on detail
5. `flutter analyze` + `flutter test` before merge
