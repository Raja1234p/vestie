# Feature: Project Detail (leader)

**Owner folder:** `lib/leader/features/project_detail/`

## Purpose

Leader-only moderation: join requests, borrow approvals, voting monitors, cancel/stop contributions, investment fund distribution.

## Dependencies

- Shared `features/project_detail/` entity & bloc
- `ProjectDetailNavigation.handleLeaderAction`
- Voting, join request, distribution APIs

## Routes

| Route | Purpose |
|-------|---------|
| `/join-requests` | Approve/reject pending members |
| `/leader/borrow-requests` | Borrow moderation |
| `/mark-project-successful` | Start success vote |
| `/leader/investment-distribution` | Distribute returns |
| `/leader/view-success-votes` | Vote progress monitor |
| `/cancel-project`, `/stop-contributions` | Lifecycle actions |

## Trace

Leader menu → `ProjectDetailNavigation.handleLeaderAction` → typed `AppRoutes.*` push

## See also

- [`PROJECT_FLOW_MAP.md`](../../../../../PROJECT_FLOW_MAP.md) §4 Leader flow
