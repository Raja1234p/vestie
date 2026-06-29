import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/core/auth/auth_token_refresh_coordinator.dart';
import 'package:vestie/core/constants/storage_keys.dart';
import 'package:vestie/core/device/device_identity.dart';
import 'package:vestie/core/device/device_info_service.dart';
import 'package:vestie/core/storage/local_storage.dart';

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

void main() {
  group('AuthTokenRefreshCoordinator', () {
    test('parseTokenPair reads flat and wrapped tokens', () {
      expect(
        AuthTokenRefreshCoordinator.parseTokenPair({
          'accessToken': 'a1',
          'refreshToken': 'r1',
        }),
        ('a1', 'r1'),
      );
      expect(
        AuthTokenRefreshCoordinator.parseTokenPair({
          'tokens': {'accessToken': 'a2', 'refreshToken': 'r2'},
        }),
        ('a2', 'r2'),
      );
    });

    test('concurrent refresh calls share one in-flight POST', () async {
      var postCount = 0;
      final storage = _MemoryStorage();
      await storage.saveString(StorageKeys.refreshToken, 'refresh-old');

      final coordinator = AuthTokenRefreshCoordinator(
        secureStorage: storage,
        deviceInfoService: _FakeDeviceInfoService(),
        refreshPoster: (refreshToken) async {
          postCount++;
          await Future<void>.delayed(const Duration(milliseconds: 30));
          expect(refreshToken, 'refresh-old');
          return ('access-new', 'refresh-new');
        },
      );

      final results = await Future.wait([
        coordinator.refresh('refresh-old'),
        coordinator.refresh('refresh-old'),
        coordinator.refresh('refresh-old'),
        coordinator.refresh('refresh-old'),
      ]);

      expect(postCount, 1);
      expect(results, everyElement('access-new'));
      expect(await storage.getString(StorageKeys.accessToken), 'access-new');
      expect(await storage.getString(StorageKeys.refreshToken), 'refresh-new');
    });

    test('skips POST when caller still holds a stale refresh token', () async {
      var postCount = 0;
      final storage = _MemoryStorage();
      await storage.saveString(StorageKeys.accessToken, 'access-new');
      await storage.saveString(StorageKeys.refreshToken, 'refresh-new');

      final coordinator = AuthTokenRefreshCoordinator(
        secureStorage: storage,
        deviceInfoService: _FakeDeviceInfoService(),
        refreshPoster: (_) async {
          postCount++;
          return ('unused', 'unused');
        },
      );

      final access = await coordinator.refresh('refresh-old');
      expect(access, 'access-new');
      expect(postCount, 0);
    });
  });
}
