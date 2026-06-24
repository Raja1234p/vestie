import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

import '../constants/api_constants.dart';
import '../constants/storage_keys.dart';
import '../device/device_info_service.dart';
import '../network/api_response_body.dart';
import '../storage/local_storage.dart';
import '../realtime/realtime_session_bridge.dart';
import '../utils/logger.dart';

typedef AuthRefreshPoster = Future<(String?, String?)> Function(
  String refreshToken,
);

/// Single-flight `POST /auth/refresh` — shared by [AuthInterceptor].
class AuthTokenRefreshCoordinator {
  final LocalStorage _secureStorage;
  final DeviceInfoService _deviceInfoService;
  final AuthRefreshPoster? _refreshPoster;

  Future<String>? _inFlight;

  AuthTokenRefreshCoordinator({
    required LocalStorage secureStorage,
    required DeviceInfoService deviceInfoService,
    AuthRefreshPoster? refreshPoster,
  }) : _secureStorage = secureStorage,
       _deviceInfoService = deviceInfoService,
       _refreshPoster = refreshPoster;

  /// Refreshes tokens and returns the new access token.
  ///
  /// Concurrent callers await the same in-flight refresh instead of posting again.
  Future<String> refresh(String refreshToken) async {
    final existing = _inFlight;
    if (existing != null) return existing;

    final future = _performRefresh(refreshToken);
    _inFlight = future;
    try {
      return await future;
    } finally {
      if (identical(_inFlight, future)) {
        _inFlight = null;
      }
    }
  }

  Future<String> _performRefresh(String refreshToken) async {
    AppLogger.info('Auth refresh: POST ${ApiConstants.refreshToken}');

    final tokens = await _postRefresh(refreshToken);
    final newAccess = tokens.$1;
    final newRefresh = tokens.$2;

    if (newAccess == null || newAccess.isEmpty) {
      throw StateError('Refresh response missing accessToken');
    }

    await _secureStorage.saveString(StorageKeys.accessToken, newAccess);
    if (newRefresh != null && newRefresh.isNotEmpty) {
      await _secureStorage.saveString(StorageKeys.refreshToken, newRefresh);
    }

    AppLogger.info('Auth refresh succeeded');
    unawaited(RealtimeSessionBridge.reconnectHubsAfterTokenRefresh());
    return newAccess;
  }

  /// Returns (accessToken, refreshToken) from flat or `tokens`-wrapped JSON.
  @visibleForTesting
  static (String?, String?) parseTokenPair(dynamic data) {
    if (data is! Map) return (null, null);
    final map = unwrapApiResponseBody(Map<String, dynamic>.from(data));
    final tokenData = map['tokens'] is Map
        ? Map<String, dynamic>.from(map['tokens'] as Map)
        : map;
    return (
      tokenData['accessToken'] as String?,
      tokenData['refreshToken'] as String?,
    );
  }

  Future<(String?, String?)> _postRefresh(String refreshToken) async {
    final poster = _refreshPoster;
    if (poster != null) return poster(refreshToken);

    final refreshDio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        connectTimeout: ApiConstants.requestTimeout,
        sendTimeout: ApiConstants.requestTimeout,
        receiveTimeout: ApiConstants.requestTimeout,
      ),
    );

    if (kDebugMode && refreshDio.httpClientAdapter is IOHttpClientAdapter) {
      (refreshDio.httpClientAdapter as IOHttpClientAdapter).createHttpClient =
          () {
            final client = HttpClient();
            client.badCertificateCallback =
                (X509Certificate cert, String host, int port) => true;
            return client;
          };
    }

    final device = await _deviceInfoService.getIdentity();
    final refreshResponse = await refreshDio.post(
      ApiConstants.refreshToken,
      data: {
        'refreshToken': refreshToken,
        'deviceId': device.id,
        'deviceName': device.name,
        'ipAddress': ApiConstants.defaultIpAddress,
      },
    );

    return parseTokenPair(refreshResponse.data);
  }
}
