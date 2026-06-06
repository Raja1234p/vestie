import 'package:flutter/foundation.dart';

import '../constants/storage_keys.dart';
import '../di/service_locator.dart';

/// Cached login state for synchronous [GoRouter.redirect] and UI guards.
///
/// This does **not** call `POST /auth/refresh`. Token renewal on API 401 is handled
/// globally by `AuthInterceptor` on the shared `DioClient`.
///
/// Call [syncFromStorage] after splash, login, OTP verify, logout, and before invite
/// navigation so the router sees tokens saved to local storage.
final class AppAuthSession extends ChangeNotifier {
  AppAuthSession._();

  static final AppAuthSession instance = AppAuthSession._();

  bool _isAuthenticated = false;

  /// Whether the user has a persisted session with a non-empty access token.
  bool get isAuthenticated => _isAuthenticated;

  /// Reads `isLoggedIn` + access token from storage into memory (no network).
  Future<void> syncFromStorage() async {
    final sl = ServiceLocator.instance;
    final isLoggedIn = await sl.sharedPrefs.getBool(StorageKeys.isLoggedIn);
    final token = await sl.secureStorage.getString(StorageKeys.accessToken);
    final next = isLoggedIn && token != null && token.trim().isNotEmpty;
    if (next == _isAuthenticated) return;
    _isAuthenticated = next;
    notifyListeners();
  }

  /// Clears cached auth immediately (e.g. after local sign-out).
  void markLoggedOut() {
    if (!_isAuthenticated) return;
    _isAuthenticated = false;
    notifyListeners();
  }

  @visibleForTesting
  void setAuthenticatedForTests(bool value) {
    if (value == _isAuthenticated) return;
    _isAuthenticated = value;
    notifyListeners();
  }
}
