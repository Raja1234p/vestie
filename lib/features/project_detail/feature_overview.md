# Feature: Project Detail (shared)

**Owner folder:** `lib/features/project_detail/`

## Purpose

Shared project detail entity, bloc, navigation helpers, member list, funds history, and investment returns shell used by both leader and member roles.

## Dependencies

- `ProjectDetailBloc`, `ProjectDetailRepository`
- `ProjectDetailNavigation`, `openProjectFromCard`
- `ProjectsSignalRService`, `ProjectPotRepository`
- Role-specific UI: `user/features/project_detail/`, `leader/features/project_detail/`

## Routes

| Route | Notes |
|-------|-------|
| `/project/detail` | Vacation / emergency detail |
| `/project/investment-detail` | Investment detail |
| `/project/member-detail` | Member profile from detail |
| `/project/group-members` | Full member list — refreshes co-leader badges after member-detail changes |
| `/project/funds-history` | Ledger view |
| `/project/contribute`, `/project/borrow` | Money sub-flows |

## Trace

`ProjectDetailScreen` → `ProjectDetailBloc` → `GetProjectDetailUseCase` → `GET /projects/{id}`

**Funds history ledger** (`/project/funds-history`): `ProjectFundsHistoryScreen` → `ProjectFundsHistoryCubit` → `GetProjectFundsHistoryUseCase` → `GET /projects/{projectId}/funds-history` (own paginated call, independent of the parent detail load). Route args (`ProjectFundsHistoryRouteArgs`) carry only `projectId` / `isInvestment` / `useBreakdownSectionTitle` — the screen's Cubit fetches `currentPotBalance`, `totalContribution`, `activeBorrows`, and paginated `entries` itself (see `architecture.mdc` §5 — route args are navigation metadata, not mock screen data). `ProjectFundsHistoryListShimmer` on initial load; `PaginatedScrollListener` + `ListLoadMoreFooter` for load-more; `AppErrorView` on initial load failure, `AppToast` on load-more failure.

Closure voting (Week 10): `ClosureVotingRepository` → `POST/GET …/closure-voting/*`  
On project detail load: Week 11+ `GET /projects/{id}` supplies `projectStatus`, `votingStatus`, `userRole`, `voting` (including `memberVotes[]`), `canStopContributions`. Legacy probe `GET …/closure-voting/active` runs for leader monitor when detail has no in-progress voting payload.

**Production member / co-leader vote flow:** while `votingStatus == pending` and the viewer has not voted, detail shows inline cast (`ProjectDetailInlineCastVote`). After vote (`hasVoted` + viewer `memberVotes[].voteStatus`), detail shows post-vote Figma UI (`ProjectDetailInlineVoteSubmitted`) — tallies + summary + Back to Home, no per-member roster on member flow.

**Leader monitor:** View Success Votes loads **`GET /projects/{id}` only** when Week 11 `voting` is present. Voting fields merge back into the open detail bloc via `ProjectDetailReloadCoordinator.mergeVotingSnapshot` (preserves pot/borrow). Legacy detail without `voting` falls back to `GET …/closure-voting/active`.

**Dev previews** (cast vote, vote outcome) are gated with `kDebugMode` only.

## See also

- `presentation/navigation/project_detail_navigation.dart`
- [`PROJECT_FLOW_MAP.md`](../../../../PROJECT_FLOW_MAP.md) §3 Project flow
