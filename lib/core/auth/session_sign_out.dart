import '../constants/storage_keys.dart';
import '../di/service_locator.dart';
import 'app_auth_session.dart';

/// Clears local session after refresh failure or forced sign-out (no API logout).
final class SessionSignOut {
  SessionSignOut._();

  static Future<void> locally() async {
    final sl = ServiceLocator.instance;
    await sl.secureStorage.remove(StorageKeys.accessToken);
    await sl.secureStorage.remove(StorageKeys.refreshToken);
    await sl.sharedPrefs.saveBool(StorageKeys.isLoggedIn, false);
    AppAuthSession.instance.markLoggedOut();
  }
}
