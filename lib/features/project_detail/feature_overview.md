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

Info card shows **Total Members** for vacation, emergency, and investment (ongoing, funded, and completed) from `membersPagination.totalCount` (else active `members[]`). Owner-only groups still show **1** (the creator). **View All Members (N)** uses the same count. Full-screen **Group Members (N)** (`/project/group-members`) uses the same floor.

**Funds history ledger** (`/project/funds-history`): `ProjectFundsHistoryScreen` → `ProjectFundsHistoryCubit` → `GetProjectFundsHistoryUseCase` → `GET /projects/{projectId}/funds-history` (own paginated call, independent of the parent detail load). Route args (`ProjectFundsHistoryRouteArgs`) carry only `projectId` / `isInvestment` / `useBreakdownSectionTitle` — the screen's Cubit fetches `currentPotBalance`, `totalContribution`, `activeBorrows`, and paginated `entries` itself (see `architecture.mdc` §5 — route args are navigation metadata, not mock screen data). `ProjectFundsHistoryListShimmer` on initial load; `PaginatedScrollListener` + `ListLoadMoreFooter` for load-more; `AppErrorView` on initial load failure, `AppToast` on load-more failure.

Closure voting (Week 10): `ClosureVotingRepository` → `POST/GET …/closure-voting/*`  
On project detail load: Week 11+ `GET /projects/{id}` supplies `projectStatus`, `votingStatus`, `userRole`, `voting` (including `memberVotes[]`), `canStopContributions`. Legacy probe `GET …/closure-voting/active` runs for leader monitor when detail has no in-progress voting payload.

**Production member / co-leader vote flow:** while `votingStatus == pending` and the viewer has not voted, detail shows inline cast (`ProjectDetailInlineCastVote`). After vote (`hasVoted` + viewer `memberVotes[].voteStatus`), detail shows post-vote Figma UI (`ProjectDetailInlineVoteSubmitted`) — tallies + summary + Back to Home, no per-member roster on member flow.

**Investment vote phases (member copy):** phase 1 stop-contributions (`isStopContributionsClosureVote`) uses dedicated Figma strings (invest/refund). Phase 2 mark-successful on funded projects (`isInvestmentMarkSuccessfulClosureVote`) uses ROI confirmation / dispute strings (`Yes, Confirm Received` / `No, Dispute`) and Total Invested / **Total Distributed (incl. ROI)** from `project.totalDistributedWithRoi` on the cast-vote screen when voting is in progress. **Approved final-closure outcome** (`SuccessVoteOutcomeScreen`) shows the same `totalDistributedWithRoi` in the green amount card (not pot/raised/contributed).

**Leader monitor:** View Success Votes loads **`GET /projects/{id}`** when Week 11 `voting` is present (open or **finalized** tallies after the window closes). Voting + lifecycle fields (`displayStatus`, `projectLifecycleState`) merge back into the open detail bloc via `ProjectDetailReloadCoordinator.mergeVotingSnapshot` (preserves pot/borrow). Legacy detail without `voting` falls back to `GET …/closure-voting/active`.

**Closure vote finalize:** backend cron auto-`POST …/closure-voting/finalize` after deadline — app does not call finalize; leaders monitor via View Success Votes; project moves to completed on detail refresh.

**Investment Distribute / Returns:** `showsInvestmentDistributionActions` on `ProjectDetailEntity` — visible on investment detail after the stop-contributions vote **passes** (`investmentContributionsAreClosed` + vote not in progress), while the project is still ongoing/funded. `investmentFundedPhase` also treats a **finalized approved** `StopContributionsVote` as funded when lifecycle fields lag behind the vote envelope. Takes priority over `showsCompletedProjectVoteOutcome` (passed stop-contrib has a finalized vote envelope but must **not** open the full-screen outcome). **Rejected** stop-contrib on ongoing investment still uses full-screen `SuccessVoteOutcomeScreen` (Vote Not Passed). **No votes** on vacation/emergency/stop-contrib → full-screen **No One Voted** outcome (`SuccessVoteOutcomeVariant.noVotesRejected`, vote summary hidden). **No votes** on investment **final closure** (mark successful) → same as **No Dispute**: stay on funded detail with Distribute Funds / Investment Returns — **no** outcome screen. Completed projects route to full-screen outcome when applicable.

## See also

- `presentation/navigation/project_detail_navigation.dart`
- [`PROJECT_FLOW_MAP.md`](../../../../PROJECT_FLOW_MAP.md) §3 Project flow
