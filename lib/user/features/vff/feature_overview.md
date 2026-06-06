# Feature: VFF (Vestie Friends & Family)

**Owner folder:** `lib/user/features/vff/`

## Purpose

Social graph hub: VFF list, requests inbox, send requests from profile or project member rows.

## Dependencies

- VFF repository & use cases (`inject_user.dart`)
- `InviteMembersMapper` (exclude existing VFF when inviting to projects)
- `ProjectDetailNavigation.sendVffRequestFromMemberRow`

## Routes

| Route | Screen |
|-------|--------|
| `/user/vff` | `UserVffScreen` |
| VFF sub-routes | Inbox, send request flows |

## Trace

`UserVffScreen` → VFF cubit → `GET /users/me/vffs`

## See also

- [`PROJECT_FLOW_MAP.md`](../../../../../PROJECT_FLOW_MAP.md) §6 VFF
