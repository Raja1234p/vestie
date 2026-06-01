import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../constants/storage_keys.dart';
import '../di/service_locator.dart';

/// Registers FCM device tokens with the Vestie API after login.
///
/// Skips silently when Firebase config files are missing or init fails so
/// non-push builds still run.
class FcmPushService {
  FcmPushService._();

  static bool _firebaseReady = false;
  static bool _tokenRefreshAttached = false;

  static Future<void> initialize() async {
    if (kIsWeb) return;
    try {
      await Firebase.initializeApp();
      _firebaseReady = true;
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();
      if (!_tokenRefreshAttached) {
        _tokenRefreshAttached = true;
        messaging.onTokenRefresh.listen((_) => syncDeviceToken());
      }
    } catch (e) {
      debugPrint('FcmPushService: Firebase init skipped ($e)');
    }
  }

  /// Call when the user reaches the post-auth shell (dashboard) or cold-starts logged in.
  static Future<void> syncDeviceToken() async {
    if (!_firebaseReady || kIsWeb) return;

    final sl = ServiceLocator.instance;
    final loggedIn =
        await sl.sharedPrefs.getBool(StorageKeys.isLoggedIn);
    if (!loggedIn) return;

    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null || token.isEmpty) return;

      final platform = Platform.isIOS ? 'iOS' : 'Android';
      final result = await sl.registerDeviceTokenUseCase(
        token: token,
        platform: platform,
      );
      await result.fold(
        (failure) async {
          debugPrint('FcmPushService: register failed (${failure.message})');
        },
        (_) async {
          await sl.sharedPrefs.saveString(StorageKeys.fcmDeviceToken, token);
        },
      );
    } catch (e) {
      debugPrint('FcmPushService: token sync failed ($e)');
    }
  }

  /// Call before clearing auth tokens on logout.
  static Future<void> unregisterStoredToken() async {
    final sl = ServiceLocator.instance;
    final stored = await sl.sharedPrefs.getString(StorageKeys.fcmDeviceToken);
    if (stored != null && stored.isNotEmpty) {
      await sl.unregisterDeviceTokenUseCase(token: stored);
      await sl.sharedPrefs.remove(StorageKeys.fcmDeviceToken);
    }

    if (!_firebaseReady || kIsWeb) return;
    try {
      await FirebaseMessaging.instance.deleteToken();
    } catch (e) {
      debugPrint('FcmPushService: deleteToken skipped ($e)');
    }
  }
}
