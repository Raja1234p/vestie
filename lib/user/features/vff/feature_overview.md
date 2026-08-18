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

FCM `VffRequestReceived` tap opens this hub on the **Requests** tab (`UserVffHubRouteArgs.requestsTab`) so the incoming friend request is visible.

After the dashboard tour (or Skip), the first visit to the hub shows a one-time ShowcaseView on the **My VFFs / Requests** tabs. Accounts that already have groups skip this overlay. Accept/decline APIs and tab taps are unchanged.

## See also

- [`PROJECT_FLOW_MAP.md`](../../../../../PROJECT_FLOW_MAP.md) §6 VFF
