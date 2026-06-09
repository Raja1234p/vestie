# Feature: Home (member)

**Owner folder:** `lib/user/features/home/`

## Purpose

"My projects" dashboard tab: list user's projects, join actions, navigation to detail, header links to notifications and VFF.

## Dependencies

- `ProjectListBloc`, `HomeSectionsCubit`
- `features/projects/`, `openProjectFromCard`
- `HomeProjectListSync` (contribution pot patches; `recordProjectLeft` on leave)
- Leave project success → `DashboardShellArgs.reloadHomeProjectList` (same as cancel project)

## Routes

| Route | Screen |
|-------|--------|
| `/dashboard` tab 0 | `HomeScreen` |

## Trace

`HomeScreen` → `ProjectListBloc` → `GET /projects?scope=mine`

## See also

- [`PROJECT_FLOW_MAP.md`](../../../../../PROJECT_FLOW_MAP.md) §3 Project flow
