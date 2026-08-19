# Feature: Notifications

**Owner folder:** `lib/features/notifications/`

## Purpose

In-app notification inbox and FCM token registration for push delivery.

## Dependencies

- `NotificationsRepository`, `inject_notifications.dart`
- `FcmPushService` (`lib/core/services/`)
- Home/Discover header entry

## Routes

| Route | Screen |
|-------|--------|
| `/notifications` | `NotificationsScreen` |

## Trace

`NotificationsScreen` → `NotificationsCubit` → `GetNotificationsUseCase` → notifications API

## Push notification tap routing

Tapping a push (foreground local banner, background tap, or terminated-launch) routes through
`PushNotificationRouter` (`lib/core/services/notifications/`), not through
this screen — see [`DOCS/push_notification_routing.md`](../../../../DOCS/push_notification_routing.md)
for the full payload shape, auth guard, and how to add a new `type`.

## Unread badge (Home / Discover bell)

- **Cubit:** `NotificationUnreadCubit` (app-level in `MainApp`, like `WalletCubit`).
- **Source of truth:** `unreadCount` from `GET /notifications` (probe with `pageSize: 1`).
- **UI:** `NotificationUnreadBadge` count pill (`1` … `99+`) on the bell in
  `NotificationFavouriteHeaderActions` (Home + Discover).
- **Refresh:** dashboard open, app resume, FCM foreground (`NotificationUnreadRefresh`),
  inbox load/mark-read sync, pop back from `/notifications`.
- **Logout:** `NotificationUnreadCubit.reset()` on profile logout success.

Foreground banners are shown by `FcmPushService` via `flutter_local_notifications`
(OS does not present FCM while the app is open). Tap payload is attached so
`VffRequestReceived` opens `/user/vff` (Requests) and `JoinRequest` opens
`/project/join-requests` for every project category. Terminated-launch taps
wait until splash has opened Home, then push that screen on top (Back returns
to Home).

## VFF pending dot (Home / Discover)

- **Cubit:** `VffPendingCubit` (app-level in `MainApp`).
- **Source of truth:** `GET /vff/received-inbox` — dot is shown when `vffRequests.isNotEmpty || projectInvites.isNotEmpty`.
- **UI:** 9×9 purple dot (key `vff_pending_dot`) on VFF icon in `NotificationFavouriteHeaderActions`.
- **Refresh:** dashboard open, app resume, FCM `VffRequestReceived` (immediate via `VffPendingRefresh.notifyPending`), hub inbox load/mutate sync, pop back from VFF hub.
- **Clear:** hub accepts/declines all requests (`VffPendingRefresh.notifyClear`), API probe returns empty.
- **Logout:** `VffPendingCubit.reset()`.

## See also

- [`FEATURE_MAP.md`](../../../../FEATURE_MAP.md)
- [`PROJECT_FLOW_MAP.md`](../../../../PROJECT_FLOW_MAP.md) §9 Notifications
- [`DOCS/push_notification_routing.md`](../../../../DOCS/push_notification_routing.md)
