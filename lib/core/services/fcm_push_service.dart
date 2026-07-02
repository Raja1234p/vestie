import 'dart:async';
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

const _androidChannelId = 'vestie_high';
const _androidChannelName = 'Vestie Notifications';
const _androidChannelDescription =
    'Vestie app notifications (deposits, updates)';

final AndroidNotificationChannel _fcmAndroidChannel = AndroidNotificationChannel(
  _androidChannelId,
  _androidChannelName,
  description: _androidChannelDescription,
  importance: Importance.high,
);

final FlutterLocalNotificationsPlugin _backgroundLocalNotifications =
    FlutterLocalNotificationsPlugin();

bool _backgroundNotificationsReady = false;

/// Top-level handler — required by FCM; must keep [@pragma('vm:entry-point')].
@pragma('vm:entry-point')
Future<void> fcmBackgroundMessageHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await _ensureBackgroundLocalNotificationsReady();
    await _showFcmLocalNotification(
      plugin: _backgroundLocalNotifications,
      message: message,
    );
    _fcmLog(
      'background message handled '
      'id=${message.messageId ?? "null"} '
      'title=${message.notification?.title ?? message.data['title'] ?? "(no-title)"}',
    );
  } catch (e, stack) {
    _fcmLog('background handler failed: $e', level: 1000);
    if (kDebugMode) {
      debugPrintStack(stackTrace: stack);
    }
  }
}

Future<void> _ensureBackgroundLocalNotificationsReady() async {
  if (_backgroundNotificationsReady) return;

  const androidInit = AndroidInitializationSettings('@drawable/ic_notification');
  await _backgroundLocalNotifications.initialize(
    const InitializationSettings(android: androidInit),
  );

  await _backgroundLocalNotifications
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(_fcmAndroidChannel);

  _backgroundNotificationsReady = true;
}

({String title, String body})? _fcmTitleAndBody(RemoteMessage message) {
  final notification = message.notification;
  var title = notification?.title?.trim() ?? '';
  var body = notification?.body?.trim() ?? '';

  if (title.isEmpty) {
    title = message.data['title']?.toString().trim() ?? '';
  }
  if (body.isEmpty) {
    body =
        message.data['body']?.toString().trim() ??
        message.data['message']?.toString().trim() ??
        '';
  }

  if (title.isEmpty && body.isEmpty) return null;
  if (title.isEmpty) title = _androidChannelName;
  return (title: title, body: body);
}

Future<void> _showFcmLocalNotification({
  required FlutterLocalNotificationsPlugin plugin,
  required RemoteMessage message,
}) async {
  final content = _fcmTitleAndBody(message);
  if (content == null) return;

  final notificationId =
      message.messageId?.hashCode ?? message.hashCode;

  await plugin.show(
    notificationId,
    content.title,
    content.body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        _fcmAndroidChannel.id,
        _fcmAndroidChannel.name,
        channelDescription: _fcmAndroidChannel.description,
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
  );
}

void _fcmLog(String message, {int level = 800}) {
  developer.log(message, name: 'FcmPushService', level: level);
  if (kDebugMode) {
    debugPrint('FcmPushService: $message');
  }
}

/// Registers FCM device tokens with the Vestie API after login.
/// Shows in-app heads-up notifications when the app is in foreground.
class FcmPushService {
  FcmPushService._();

  static bool _backgroundHandlerAttached = false;
  static bool _firebaseReady = false;
  static bool _tokenRefreshAttached = false;
  static Future<void>? _syncInFlight;
  static String? _sessionSyncedToken;

  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Call immediately after [Firebase.initializeApp] — before [runApp].
  static void attachBackgroundMessageHandler() {
    if (_backgroundHandlerAttached || kIsWeb) return;
    FirebaseMessaging.onBackgroundMessage(fcmBackgroundMessageHandler);
    _backgroundHandlerAttached = true;
    _fcmLog('background handler attached');
  }

  static Future<void> initialize() async {
    if (kIsWeb) return;
    _fcmLog('initialize() start');
    try {
      attachBackgroundMessageHandler();

      _firebaseReady = true;
      final messaging = FirebaseMessaging.instance;

      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(_fcmAndroidChannel);

      const androidInit = AndroidInitializationSettings('@drawable/ic_notification');
      const iosInit = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        requestProvisionalPermission: false,
      );
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      _fcmLog('Notification permission: ${settings.authorizationStatus}');

      final fcmToken = await messaging.getToken();
      _fcmLog('FCM token: ${fcmToken != null ? _maskToken(fcmToken) : "null"}');

      await _localNotifications.initialize(
        const InitializationSettings(android: androidInit, iOS: iosInit),
      );

      if (Platform.isAndroid) {
        await _localNotifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission();
      }

      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      FirebaseMessaging.onMessage.listen(_onForegroundMessage);

      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        _fcmLog(
          'onMessageOpenedApp: '
          'title=${message.notification?.title ?? message.data['title'] ?? "(no-title)"}',
        );
      });

      if (!_tokenRefreshAttached) {
        _tokenRefreshAttached = true;
        messaging.onTokenRefresh.listen((newToken) {
          _fcmLog('onTokenRefresh: ${_maskToken(newToken)}');
          syncDeviceToken(force: true);
        });
      }
    } catch (e, stack) {
      _fcmLog('initialize() failed: $e', level: 1000);
      if (kDebugMode) {
        debugPrintStack(stackTrace: stack);
      }
    }
  }

  static void _onForegroundMessage(RemoteMessage message) {
    final content = _fcmTitleAndBody(message);
    if (content == null) {
      _fcmLog('foreground: no displayable title/body');
      return;
    }

    unawaited(
      _showFcmLocalNotification(
        plugin: _localNotifications,
        message: message,
      ).then(
        (_) => _fcmLog('foreground notification shown: ${content.title}'),
        onError: (Object e) =>
            _fcmLog('foreground show failed: $e', level: 1000),
      ),
    );
  }

  /// Registers the current FCM token with `POST /notifications/device-token`.
  ///
  /// [force] — when `true`, always hits the API even if the token matches local
  /// storage (use after login and on [FirebaseMessaging.onTokenRefresh]). When
  /// `false`, skips redundant calls when the token is unchanged this session.
  static Future<void> syncDeviceToken({bool force = false}) async {
    if (!_firebaseReady || kIsWeb) return;

    if (_syncInFlight != null) {
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
    if (!loggedIn) return;

    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null || token.isEmpty) {
        _fcmLog('token sync: getToken empty', level: 1000);
        return;
      }

      if (!force && _sessionSyncedToken == token) return;

      if (!force) {
        final stored = await sl.sharedPrefs.getString(
          StorageKeys.fcmDeviceToken,
        );
        if (stored == token) {
          _sessionSyncedToken = token;
          return;
        }
      }

      final platform = Platform.isIOS ? 'iOS' : 'Android';
      final result = await sl.registerDeviceTokenUseCase(
        token: token,
        platform: platform,
      );
      await result.fold(
        (failure) async {
          _fcmLog('registerDeviceToken failed: ${failure.message}', level: 1000);
        },
        (_) async {
          await sl.sharedPrefs.saveString(StorageKeys.fcmDeviceToken, token);
          _sessionSyncedToken = token;
          _fcmLog('registerDeviceToken success ${_maskToken(token)}');
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

  static String _maskToken(String token) {
    if (token.length <= 10) return token;
    return '${token.substring(0, 6)}...${token.substring(token.length - 4)}';
  }
}
