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

## See also

- [`FEATURE_MAP.md`](../../../../FEATURE_MAP.md)
- [`PROJECT_FLOW_MAP.md`](../../../../PROJECT_FLOW_MAP.md) §9 Notifications
