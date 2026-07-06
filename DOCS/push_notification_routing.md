# Push notification routing

How a tapped FCM push notification opens the right screen, and how to add a
new notification `type` → route mapping.

**Code:**

- `lib/core/services/fcm_push_service.dart` — FCM lifecycle (permissions, foreground/background display, de-dupe, tap listeners)
- `lib/core/services/notifications/push_notification_payload.dart` — typed parsing of the FCM `data` map
- `lib/core/services/notifications/push_notification_router.dart` — tap → navigation

---

## 1. Wire shape

Notifications arrive as an FCM `RemoteMessage` with a flat `data` map. Example
(`ProjectCreated`):

```json
{
  "type": "ProjectCreated",
  "title": "Project Created",
  "body": "Your project ddd has been created successfully.",
  "payload": "{\"projectId\":\"4f78d1af-4350-4e86-86b1-b7ed128b1c89\",\"projectName\":\"ddd\"}"
}
```

Example (`WithdrawalFailed`) — note the backend uses **`metadata`** instead of
`payload` for this type:

```json
{
  "type": "WithdrawalFailed",
  "title": "Withdrawal Failed",
  "body": "Your withdrawal of $500 could not be processed. Please try again.",
  "metadata": "{\"withdrawalId\":\"4c63d3e2-84f6-4917-b7e8-095445e9b4d6\",\"amount\":500.00,\"currency\":\"USD\",\"status\":\"Failed\",\"failureReason\":\"Your account has insufficient funds to cover the transfer.\"}"
}
```

- `type` — discriminator, maps to `PushNotificationType`.
- `title` / `body` — display copy (also used as `notification.title/body` fallback when the backend sends a data-only message).
- `payload` **or** `metadata` — a **JSON-encoded string** (not a nested map) holding type-specific fields; the backend is inconsistent about which field name it uses per type, so `PushNotificationPayload.fromData` checks `payload` first, then falls back to `metadata`. `_decodePayload` also accepts either a real map or a JSON string for backend flexibility, and returns `{}` on malformed input rather than throwing.

## 2. `PushNotificationPayload`

`PushNotificationPayload.fromData(message.data)` parses the wire shape above
into a typed object:

```dart
class PushNotificationPayload {
  final PushNotificationType type;
  final String title;
  final String body;
  final Map<String, dynamic> payload;

  String? get projectId => payload['projectId']?.toString();
  String? get projectName => payload['projectName']?.toString();
}
```

`PushNotificationType.fromWire` maps the backend string to an enum value and
defaults to `PushNotificationType.unknown` for anything not yet handled —
unknown types open the **Home** tab (no crash, no toast).

## 3. `PushNotificationRouter`

`FcmPushService` has no `BuildContext` — it runs during bootstrap
(`getInitialMessage` for cold start) and from FCM's own stream listeners — so
navigation goes through the app's `GoRouter` instance directly, the same
pattern as `ProjectInviteDeepLinkService`.

```text
FcmPushService._onNotificationTapped(RemoteMessage)
  → PushNotificationPayload.fromData(message.data)
  → PushNotificationRouter.handleTap(payload)
      → router attached?  no → queue as _pendingTap, replay on attach()
                           yes → _route(payload)
      → switch (payload.type) { ... }
```

- **`attach(router)`** — called once from `MainApp`'s post-frame callback (`lib/app/main_app.dart`), mirroring `ProjectInviteDeepLinkService.start`. Replays a queued cold-start tap once the router/navigator exist.
- **`handleTap(payload)`** — called from every tap path: `FirebaseMessaging.onMessageOpenedApp` (background tap) and `getInitialMessage()` (terminated-launch tap).
- **Auth guard** — dashboard/project routes bail out if `AppAuthSession.instance.isAuthenticated` is false (never deep-link into a screen behind auth).
- **Category resolution** — the notify payload only carries `projectId`, not project category, and category decides the route (`/project/detail` vs `/project/investment-detail`). The router fetches `GET /projects/{id}` via `ServiceLocator.instance.projectDetailRepository.getProjectDetail` first, then calls `openProjectDetailById` with the resolved `category.isInvestment`. If the fetch fails, navigation is silently skipped (stale/deleted project) rather than erroring.

## 4. Adding a new notification type

1. Add the wire value to `PushNotificationType` + `fromWire` in `push_notification_payload.dart`.
2. Add any new payload fields as typed getters on `PushNotificationPayload` (never read `payload['x']` directly from the router or UI).
3. Add a `case` in `PushNotificationRouter._route` that pushes the right `AppRoutes` entry with a typed route-args class (never `context.push('/raw/path')`).
4. If the target screen needs data not in the notify payload (e.g. category, name), fetch it via the existing repository/use case before navigating — do not thread raw API JSON through the router.
5. Update this doc's wire-shape table and the type list below.

## 5. Current type coverage

| `type` | Payload fields | Route |
|---|---|---|
| `ProjectCreated` | `projectId`, `projectName` | `/project/detail` or `/project/investment-detail` (resolved via `GET /projects/{id}`) |
| `WithdrawalFailed` | `withdrawalId`, `amount`, `currency`, `status`, `failureReason` (under `metadata`) | Dashboard Wallet tab |
| `Deposit*` / copy with **withdrawal** or **deposit** in `type`, `title`, or `body` | varies | Dashboard Wallet tab (same as `WithdrawalFailed` — resolved by `PushNotificationType.walletTypeIfTextMatches`) |
| _(anything else)_ | — | Dashboard Home tab (`initialTabIndex: 0`) — safe fallback, no crash |

## 6. iOS duplicate notification fix (context)

iOS 18 has a known bug (flutterfire#13366) where enabling
`setForegroundNotificationPresentationOptions(alert: true, ...)` causes
`FirebaseMessaging.onMessage` to fire twice for the same message, and races
with the OS's own foreground presentation — producing two visible
notifications for one push. `FcmPushService` avoids this by:

- Keeping iOS foreground auto-presentation **off** (`alert/badge/sound: false`) — the app is the single source of truth for foreground display on both platforms.
- De-duping foreground messages on `message.messageId` (`_lastForegroundMessageId`) as a defensive second layer.
- Never presenting a notification for messages the OS already shows itself (background/terminated with a `notification` payload) — `fcmBackgroundMessageHandler` returns early when `message.notification != null`.

See `fcm_push_service.dart` class doc for the full state table (foreground /
background / terminated × notification / data-only).

## See also

- [`PROJECT_FLOW_MAP.md`](../PROJECT_FLOW_MAP.md) §9 Notifications
- [`FEATURE_MAP.md`](../FEATURE_MAP.md) Notifications
- `lib/core/services/project_invite_deep_link_service.dart` — `ProjectInviteDeepLinkService` (same no-`BuildContext` router-attach pattern for `vestie://` deep links)
