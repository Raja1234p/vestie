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

Tapping a push (background tap or terminated-launch) routes through
`PushNotificationRouter` (`lib/core/services/notifications/`), not through
this screen — see [`DOCS/push_notification_routing.md`](../../../../DOCS/push_notification_routing.md)
for the full payload shape, auth guard, and how to add a new `type`.

## See also

- [`FEATURE_MAP.md`](../../../../FEATURE_MAP.md)
- [`PROJECT_FLOW_MAP.md`](../../../../PROJECT_FLOW_MAP.md) §9 Notifications
- [`DOCS/push_notification_routing.md`](../../../../DOCS/push_notification_routing.md)
