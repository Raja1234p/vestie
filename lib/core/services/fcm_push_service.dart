import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../constants/storage_keys.dart';
import '../di/service_locator.dart';

/// Top-level handler — required to be a plain static function by FCM.
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    debugPrint(
      'FcmPushService: background message received '
      'id=${message.messageId ?? "null"} '
      'title=${message.notification?.title ?? "(no-title)"} '
      'type=${message.data['type'] ?? "(no-type)"}',
    );
  }
}

/// Registers FCM device tokens with the Vestie API after login.
/// Shows in-app heads-up notifications when the app is in foreground.
class FcmPushService {
  FcmPushService._();
  static const _logTag = 'FcmPushService';

  static bool _firebaseReady = false;
  static bool _tokenRefreshAttached = false;
  static Future<void>? _syncInFlight;
  static String? _sessionSyncedToken;

  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const _androidChannel = AndroidNotificationChannel(
    'vestie_high',
    'Vestie Notifications',
    description: 'Vestie app notifications (deposits, updates)',
    importance: Importance.high,
  );

  static Future<void> initialize() async {
    if (kIsWeb) return;
    _log('initialize() start');
    try {
      await Firebase.initializeApp();
      _firebaseReady = true;
      _log('Firebase initialized');

      final messaging = FirebaseMessaging.instance;

      // Do NOT request permission here — the permission prompt is shown via
      // AppPermissionHelper.maybePromptNotificationsOnDashboard after login.
      // Calling requestPermission() in initialize() would pop the OS dialog
      // before the user has seen any UI (e.g. still on the splash/login screen).

      // Background / terminated handler.
      FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
      _log('Background handler attached');

      // Create Android notification channel.
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(_androidChannel);
      _log('Android notification channel ready: ${_androidChannel.id}');

      // Init local notifications.
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInit = DarwinInitializationSettings();
      await _localNotifications.initialize(
        const InitializationSettings(android: androidInit, iOS: iosInit),
      );
      _log('Local notifications initialized');

      // iOS: show foreground notifications as banners.
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      _log('iOS foreground presentation options applied');

      // Foreground message → show local notification.
      FirebaseMessaging.onMessage.listen(_onForegroundMessage);
      _log('onMessage listener attached');

      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        _log(
          'onMessageOpenedApp: id=${message.messageId ?? "null"} '
          'title=${message.notification?.title ?? "(no-title)"} '
          'type=${message.data['type'] ?? "(no-type)"}',
        );
      });
      _log('onMessageOpenedApp listener attached');

      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        _log(
          'getInitialMessage: id=${initialMessage.messageId ?? "null"} '
          'title=${initialMessage.notification?.title ?? "(no-title)"} '
          'type=${initialMessage.data['type'] ?? "(no-type)"}',
        );
      } else {
        _log('getInitialMessage: none');
      }

      if (!_tokenRefreshAttached) {
        _tokenRefreshAttached = true;
        messaging.onTokenRefresh.listen((newToken) {
          _log(
            'onTokenRefresh received: token=${_maskToken(newToken)}; '
            'syncDeviceToken() will run',
          );
          syncDeviceToken();
        });
        _log('onTokenRefresh listener attached');
      }
    } catch (e) {
      _log('initialize() failed: $e');
    }
  }

  static void _onForegroundMessage(RemoteMessage message) {
    _log(
      'onMessage foreground: id=${message.messageId ?? "null"} '
      'title=${message.notification?.title ?? "(no-title)"} '
      'type=${message.data['type'] ?? "(no-type)"} '
      'hasNotification=${message.notification != null}',
    );
    final notification = message.notification;
    if (notification == null) {
      _log('foreground message has no notification payload; skip local show');
      return;
    }

    final title = notification.title ?? '';
    final body = notification.body ?? '';
    if (title.isEmpty && body.isEmpty) {
      _log('foreground message has empty title/body; skip local show');
      return;
    }

    _localNotifications.show(
      notification.hashCode,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
    _log(
      'local notification shown: id=${notification.hashCode} '
      'title=$title',
    );
  }

  /// Call once when the user reaches the post-auth shell (dashboard).
  ///
  /// Skips the API when the FCM token is unchanged; coalesces concurrent calls.
  static Future<void> syncDeviceToken({bool force = false}) async {
    _log('syncDeviceToken(force: $force) called');
    if (!_firebaseReady || kIsWeb) {
      _log(
        'syncDeviceToken skipped: firebaseReady=$_firebaseReady, kIsWeb=$kIsWeb',
      );
      return;
    }

    if (_syncInFlight != null) {
      _log('syncDeviceToken coalesced: another sync already running');
      await _syncInFlight;
      return;
    }

    _syncInFlight = _syncDeviceTokenBody(force: force);
    try {
      await _syncInFlight;
    } finally {
      _syncInFlight = null;
    }
  }

  static Future<void> _syncDeviceTokenBody({required bool force}) async {
    final sl = ServiceLocator.instance;
    final loggedIn = await sl.sharedPrefs.getBool(StorageKeys.isLoggedIn);
    if (!loggedIn) {
      _log('token sync skipped: user is not logged in');
      return;
    }

    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null || token.isEmpty) {
        _log('token sync skipped: getToken returned null/empty');
        return;
      }
      _log('FCM token fetched: ${_maskToken(token)}');

      if (!force && _sessionSyncedToken == token) {
        _log('token sync skipped: same as sessionSyncedToken');
        return;
      }

      if (!force) {
        final stored = await sl.sharedPrefs.getString(
          StorageKeys.fcmDeviceToken,
        );
        if (stored == token) {
          _sessionSyncedToken = token;
          _log('token sync skipped: same as persisted token');
          return;
        }
      }

      final platform = Platform.isIOS ? 'iOS' : 'Android';
      _log('registerDeviceToken API call start (platform=$platform)');
      final result = await sl.registerDeviceTokenUseCase(
        token: token,
        platform: platform,
      );
      await result.fold(
        (failure) async {
          _log('registerDeviceToken API failed: ${failure.message}');
        },
        (_) async {
          await sl.sharedPrefs.saveString(StorageKeys.fcmDeviceToken, token);
          _sessionSyncedToken = token;
          _log(
            'registerDeviceToken API success; token persisted ${_maskToken(token)}',
          );
        },
      );
    } catch (e) {
      _log('token sync exception: $e');
    }
  }

  /// Call before clearing auth tokens on logout.
  static Future<void> unregisterStoredToken() async {
    _log('unregisterStoredToken() called');
    _sessionSyncedToken = null;

    final sl = ServiceLocator.instance;
    final stored = await sl.sharedPrefs.getString(StorageKeys.fcmDeviceToken);
    if (stored != null && stored.isNotEmpty) {
      _log('unregisterDeviceToken API call start: ${_maskToken(stored)}');
      await sl.unregisterDeviceTokenUseCase(token: stored);
      await sl.sharedPrefs.remove(StorageKeys.fcmDeviceToken);
      _log('unregisterDeviceToken API success');
    }

    if (!_firebaseReady || kIsWeb) return;
    try {
      await FirebaseMessaging.instance.deleteToken();
      _log('FirebaseMessaging.deleteToken success');
    } catch (e) {
      _log('deleteToken skipped: $e');
    }
  }

  static void _log(String message) {
    if (kDebugMode) {
      debugPrint('$_logTag: $message');
    }
  }

  static String _maskToken(String token) {
    if (token.length <= 10) return token;
    return '${token.substring(0, 6)}...${token.substring(token.length - 4)}';
  }
}
