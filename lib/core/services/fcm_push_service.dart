import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io' show Platform;
import 'dart:ui' show Color;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../firebase_options.dart';
import '../constants/storage_keys.dart';
import '../di/service_locator.dart';
import 'notifications/notification_unread_refresh.dart';
import 'notifications/push_notification_payload.dart';
import 'notifications/push_notification_router.dart';

/// FCM push notifications — [official pattern](https://firebase.google.com/docs/cloud-messaging/flutter/receive):
///
/// | State | Notification payload | Data-only |
/// |---|---|---|
/// | Foreground (Android + iOS) | app shows it — OS never presents foreground messages by default on either platform | app shows it |
/// | Background / terminated | OS always shows it (cannot be suppressed) | [fcmBackgroundMessageHandler] shows it |
///
/// We deliberately do **not** override
/// [FirebaseMessaging.setForegroundNotificationPresentationOptions] to let iOS
/// auto-present — that path is known to double-fire `onMessage` on iOS 18
/// (flutterfire#13366) and race with our own local notification, producing
/// the exact duplicate this service exists to avoid. Instead the app is the
/// single source of truth for foreground display on both platforms, and the
/// OS is the single source of truth for background/terminated display —
/// the two never overlap.
const _androidChannelId = 'vestie_high';
const _androidChannelName = 'Vestie Notifications';
const _androidChannel = AndroidNotificationChannel(
  _androidChannelId,
  _androidChannelName,
  description: 'Vestie app notifications (deposits, updates)',
  importance: Importance.high,
);

final _localNotifications = FlutterLocalNotificationsPlugin();
bool _localNotificationsReady = false;

/// Top-level background/terminated handler — required by FCM (`@pragma('vm:entry-point')`).
@pragma('vm:entry-point')
Future<void> fcmBackgroundMessageHandler(RemoteMessage message) async {
  _logPayload('background', message);
  if (message.notification != null) return; // OS already shows this.
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await _ensureLocalNotificationsReady();
    await _showLocalNotification(message);
  } catch (e, stack) {
    _fcmLog('background handler failed: $e', level: 1000);
    if (kDebugMode) debugPrintStack(stackTrace: stack);
  }
}

/// Registers device tokens with the Vestie API and displays notifications the
/// OS does not present itself (see table above).
class FcmPushService {
  FcmPushService._();

  static bool _backgroundHandlerAttached = false;
  static bool _firebaseReady = false;
  static bool _tokenRefreshAttached = false;
  static Future<void>? _syncInFlight;
  static String? _sessionSyncedToken;

  /// Call immediately after [Firebase.initializeApp] — before `runApp`.
  static void attachBackgroundMessageHandler() {
    if (_backgroundHandlerAttached || kIsWeb) return;
    FirebaseMessaging.onBackgroundMessage(fcmBackgroundMessageHandler);
    _backgroundHandlerAttached = true;
  }

  static Future<void> initialize() async {
    if (kIsWeb) return;
    try {
      attachBackgroundMessageHandler();
      _firebaseReady = true;

      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      _fcmLog('permission: ${settings.authorizationStatus}');

      await _ensureLocalNotificationsReady();

      // Runtime POST_NOTIFICATIONS prompt (Android 13+) — requires a foreground
      // Activity, so this must only run here, never from a background isolate.
      if (Platform.isAndroid) {
        await _localNotifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission();
      }

      // Keep iOS foreground auto-presentation off (its default) — see class
      // doc for why. The app always shows its own local notification instead.
      await messaging.setForegroundNotificationPresentationOptions(
        alert: false,
        badge: false,
        sound: false,
      );

      FirebaseMessaging.onMessage.listen(_onForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_onNotificationTapped);

      // Terminated-state launch via notification tap (official docs: handle
      // both this and onMessageOpenedApp for full interaction coverage).
      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        _onNotificationTapped(initialMessage);
      } else {
        await _replayLocalNotificationLaunch();
      }

      if (!_tokenRefreshAttached) {
        _tokenRefreshAttached = true;
        messaging.onTokenRefresh.listen((_) => syncDeviceToken(force: true));
      }
    } catch (e, stack) {
      _fcmLog('initialize() failed: $e', level: 1000);
      if (kDebugMode) debugPrintStack(stackTrace: stack);
    }
  }

  static String? _lastForegroundMessageId;

  static void _onForegroundMessage(RemoteMessage message) {
    _logPayload('foreground', message);

    // iOS 18 is known to fire onMessage twice for the same payload
    // (flutterfire#13366) — de-dupe on messageId as Firebase recommends.
    final id = message.messageId;
    if (id != null && id == _lastForegroundMessageId) return;
    _lastForegroundMessageId = id;

    unawaited(_showLocalNotification(message));
    unawaited(NotificationUnreadRefresh.requestRefresh());
  }

  /// Fires when the user taps a notification (background tap or terminated
  /// launch). Routes via [PushNotificationRouter], which switches on
  /// [PushNotificationPayload.type] — see that class for the wire shape.
  static void _onNotificationTapped(RemoteMessage message) {
    _logPayload('tapped', message);
    unawaited(NotificationUnreadRefresh.requestRefresh());
    PushNotificationRouter.handleTap(
      PushNotificationPayload.fromData(message.data),
    );
  }

  static void _onLocalNotificationResponse(NotificationResponse response) {
    final raw = response.payload;
    if (raw == null || raw.isEmpty) return;
    unawaited(NotificationUnreadRefresh.requestRefresh());
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return;
      PushNotificationRouter.handleTap(
        PushNotificationPayload.fromData(Map<String, dynamic>.from(decoded)),
      );
    } catch (e) {
      _fcmLog('local tap payload parse failed: $e', level: 1000);
    }
  }

  static Future<void> _replayLocalNotificationLaunch() async {
    try {
      final launch =
          await _localNotifications.getNotificationAppLaunchDetails();
      final response = launch?.notificationResponse;
      if (launch?.didNotificationLaunchApp == true && response != null) {
        _onLocalNotificationResponse(response);
      }
    } catch (e) {
      _fcmLog('local launch replay failed: $e', level: 1000);
    }
  }

  /// Registers the current FCM token with `POST /notifications/device-token`.
  ///
  /// [force] always hits the API (use after login and on token refresh);
  /// otherwise skips redundant calls when the token is unchanged this session.
  static Future<void> syncDeviceToken({bool force = false}) async {
    if (!_firebaseReady || kIsWeb) return;
    if (_syncInFlight != null) return _syncInFlight;

    _syncInFlight = _syncDeviceTokenBody(force: force);
    try {
      await _syncInFlight;
    } finally {
      _syncInFlight = null;
    }
  }

  static Future<void> _syncDeviceTokenBody({required bool force}) async {
    final sl = ServiceLocator.instance;
    if (!await sl.sharedPrefs.getBool(StorageKeys.isLoggedIn)) return;

    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null || token.isEmpty) return;
      if (!force && token == _sessionSyncedToken) return;
      if (!force &&
          token == await sl.sharedPrefs.getString(StorageKeys.fcmDeviceToken)) {
        _sessionSyncedToken = token;
        return;
      }

      final result = await sl.registerDeviceTokenUseCase(
        token: token,
        platform: Platform.isIOS ? 'iOS' : 'Android',
      );
      await result.fold(
        (failure) async => _fcmLog('registerDeviceToken failed: ${failure.message}', level: 1000),
        (_) async {
          await sl.sharedPrefs.saveString(StorageKeys.fcmDeviceToken, token);
          _sessionSyncedToken = token;
        },
      );
    } catch (e) {
      _fcmLog('token sync exception: $e', level: 1000);
    }
  }

  static Future<void> unregisterStoredToken() async {
    _sessionSyncedToken = null;

    final sl = ServiceLocator.instance;
    final stored = await sl.sharedPrefs.getString(StorageKeys.fcmDeviceToken);
    if (stored != null && stored.isNotEmpty) {
      await sl.unregisterDeviceTokenUseCase(token: stored);
      await sl.sharedPrefs.remove(StorageKeys.fcmDeviceToken);
    }

    if (!_firebaseReady || kIsWeb) return;
    try {
      await FirebaseMessaging.instance.deleteToken();
    } catch (_) {}
  }
}

Future<void> _ensureLocalNotificationsReady() async {
  if (_localNotificationsReady) return;

  await _localNotifications.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@drawable/ic_notification'),
      iOS: DarwinInitializationSettings(
        // Permission is requested via FirebaseMessaging.requestPermission above.
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    ),
    onDidReceiveNotificationResponse: FcmPushService._onLocalNotificationResponse,
  );

  await _localNotifications
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(_androidChannel);

  _localNotificationsReady = true;
}

/// Shows a heads-up local notification for messages the OS does not present
/// itself: every foreground message, plus data-only background messages.
Future<void> _showLocalNotification(RemoteMessage message) async {
  try {
    await _ensureLocalNotificationsReady();
    final notification = message.notification;
    final title = notification?.title ?? message.data['title']?.toString() ?? '';
    final body =
        notification?.body ??
        message.data['body']?.toString() ??
        message.data['message']?.toString() ??
        '';
    if (title.isEmpty && body.isEmpty) return;

    final data = Map<String, dynamic>.from(message.data);
    if (title.isNotEmpty) data.putIfAbsent('title', () => title);
    if (body.isNotEmpty) data.putIfAbsent('body', () => body);

    await _localNotifications.show(
      _localNotificationId(message),
      title.isEmpty ? _androidChannelName : title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@drawable/ic_notification',
          color: const Color(0xFF4C24A0),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(data),
    );
  } catch (e, stack) {
    _fcmLog('local notification display failed: $e', level: 1000);
    if (kDebugMode) debugPrintStack(stackTrace: stack);
  }
}

int _localNotificationId(RemoteMessage message) {
  final raw = message.messageId?.hashCode ?? message.hashCode;
  final id = raw & 0x7fffffff;
  return id == 0 ? 1 : id;
}

void _fcmLog(String message, {int level = 800}) {
  developer.log(message, name: 'FcmPushService', level: level);
  if (kDebugMode) debugPrint('FcmPushService: $message');
}

/// Logs the full payload shape (title/body/data) for a given [event] —
/// use this to see what the backend actually sends before wiring routing.
///
/// Always prints (not gated by [kDebugMode]) so it shows up in `adb logcat`
/// / Xcode console on release/profile builds too, not just `flutter run`.
void _logPayload(String event, RemoteMessage message) {
  final payload =
      'FcmPushService: $event | id=${message.messageId} '
      'notification.title=${message.notification?.title} '
      'notification.body=${message.notification?.body} '
      'data=${message.data}';
  developer.log(payload, name: 'FcmPushService');
  debugPrint(payload);
}
