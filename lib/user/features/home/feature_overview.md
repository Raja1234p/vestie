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

List `totalJoinedMember` is **Total Members** on home/discover/completed cards (vacation, emergency, investment). List `memberCount` is eligible voters for vote-outcome copy only.

Missing or `0` `totalJoinedMember`: the card hides **Total Members** (no string, no `0`).

First dashboard visit shows a one-time **ShowcaseView** overlay on the tab bar + VFF icon (Skip / Next) **only when Home has no groups**. Accounts that already have projects skip every tour so existing taps and flows are unchanged.

## See also

- [`PROJECT_FLOW_MAP.md`](../../../../../PROJECT_FLOW_MAP.md) §3 Project flow
