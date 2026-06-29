import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/core/auth/auth_token_refresh_coordinator.dart';
import 'package:vestie/core/constants/api_constants.dart';
import 'package:vestie/core/constants/storage_keys.dart';
import 'package:vestie/core/device/device_identity.dart';
import 'package:vestie/core/device/device_info_service.dart';
import 'package:vestie/core/network/interceptors/auth_interceptor.dart';
import 'package:vestie/core/storage/local_storage.dart';

void main() {
  group('AuthInterceptor.shouldSignOutOn401', () {
    test(
      'does not sign out when request was already retried after refresh',
      () {
        expect(
          AuthInterceptor.shouldSignOutOn401(
            path: '/projects/1',
            isAuthRetry: true,
          ),
          isFalse,
        );
      },
    );

    test('does not sign out for login or verify failures', () {
      expect(
        AuthInterceptor.shouldSignOutOn401(
          path: ApiConstants.login,
          isAuthRetry: false,
        ),
        isFalse,
      );
      expect(
        AuthInterceptor.shouldSignOutOn401(
          path: ApiConstants.verifyEmail,
          isAuthRetry: false,
        ),
        isFalse,
      );
    });

    test('does not sign out for normal API 401 before refresh attempt', () {
      expect(
        AuthInterceptor.shouldSignOutOn401(
          path: '/projects/1',
          isAuthRetry: false,
        ),
        isFalse,
      );
    });

    test('signs out when refresh endpoint returns 401', () {
      expect(
        AuthInterceptor.shouldSignOutOn401(
          path: ApiConstants.refreshToken,
          isAuthRetry: false,
        ),
        isTrue,
      );
    });
  });

  group('AuthInterceptor.shouldRetryWithUpdatedAccessToken', () {
    test('retries when storage already has a newer access token', () {
      expect(
        AuthInterceptor.shouldRetryWithUpdatedAccessToken(
          failedBearer: 'expired-token',
          storedAccess: 'fresh-token',
        ),
        isTrue,
      );
    });

    test('does not skip refresh when stored token matches failed request', () {
      expect(
        AuthInterceptor.shouldRetryWithUpdatedAccessToken(
          failedBearer: 'same-token',
          storedAccess: 'same-token',
        ),
        isFalse,
      );
    });

    test('does not skip refresh when failed bearer could not be parsed', () {
      expect(
        AuthInterceptor.shouldRetryWithUpdatedAccessToken(
          failedBearer: null,
          storedAccess: 'fresh-token',
        ),
        isFalse,
      );
    });
  });

  group('AuthInterceptor sequential 401 dedup', () {
    test(
      'after first refresh saves a new access token peers skip another POST',
      () async {
        var refreshPostCount = 0;
        final storage = _MemoryStorage();
        await storage.saveString(StorageKeys.accessToken, 'expired-access');
        await storage.saveString(StorageKeys.refreshToken, 'refresh-v1');

        final coordinator = AuthTokenRefreshCoordinator(
          secureStorage: storage,
          deviceInfoService: _FakeDeviceInfoService(),
          refreshPoster: (token) async {
            refreshPostCount++;
            expect(token, 'refresh-v1');
            return ('fresh-access', 'refresh-v2');
          },
        );

        expect(
          AuthInterceptor.shouldRetryWithUpdatedAccessToken(
            failedBearer: 'expired-access',
            storedAccess: 'expired-access',
          ),
          isFalse,
        );

        final firstAccess = await coordinator.refresh('refresh-v1');
        expect(firstAccess, 'fresh-access');
        expect(refreshPostCount, 1);

        expect(
          AuthInterceptor.shouldRetryWithUpdatedAccessToken(
            failedBearer: 'expired-access',
            storedAccess: await storage.getString(StorageKeys.accessToken),
          ),
          isTrue,
        );

        final peerAccess = await coordinator.refresh('refresh-v1');
        expect(peerAccess, 'fresh-access');
        expect(refreshPostCount, 1);
      },
    );

    test(
      'coordinator skips POST when refresh token was rotated by a peer refresh',
      () async {
        var refreshPostCount = 0;
        final storage = _MemoryStorage();
        await storage.saveString(StorageKeys.accessToken, 'fresh-access');
        await storage.saveString(StorageKeys.refreshToken, 'refresh-v2');

        final coordinator = AuthTokenRefreshCoordinator(
          secureStorage: storage,
          deviceInfoService: _FakeDeviceInfoService(),
          refreshPoster: (_) async {
            refreshPostCount++;
            return ('unused', 'unused');
          },
        );

        final access = await coordinator.refresh('refresh-v1');
        expect(access, 'fresh-access');
        expect(refreshPostCount, 0);
      },
    );
  });
}

class _MemoryStorage implements LocalStorage {
  final Map<String, String> _data = {};

  @override
  Future<void> clear() async => _data.clear();

  @override
  Future<bool> getBool(String key, {bool defaultValue = false}) async =>
      _data[key] == 'true';

  @override
  Future<String?> getString(String key) async => _data[key];

  @override
  Future<void> remove(String key) async => _data.remove(key);

  @override
  Future<void> saveBool(String key, bool value) async =>
      _data[key] = value.toString();

  @override
  Future<void> saveString(String key, String value) async => _data[key] = value;
}

class _FakeDeviceInfoService implements DeviceInfoService {
  @override
  Future<DeviceIdentity> getIdentity() async {
    return const DeviceIdentity(id: 'device-test', name: 'test-device');
  }
}
