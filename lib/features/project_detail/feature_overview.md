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

Closure voting (Week 10): `ClosureVotingRepository` → `POST/GET …/closure-voting/*`  
On project detail load: Week 11+ `GET /projects/{id}` supplies `projectStatus`, `votingStatus`, `userRole`, `voting`. Legacy probe `GET …/closure-voting/active` runs only when detail has no in-progress voting.

Production: **status banner** + **voting card** on detail; members **cast inline** (`ProjectDetailInlineCastVote`). **View Votes** still uses monitor screen + `GET active`.

## See also

- `presentation/navigation/project_detail_navigation.dart`
- [`PROJECT_FLOW_MAP.md`](../../../../PROJECT_FLOW_MAP.md) §3 Project flow
