import '../constants/storage_keys.dart';
import '../di/service_locator.dart';

/// Persists an invite code until the user finishes auth and opens the invitation screen.
final class PendingProjectInviteStore {
  PendingProjectInviteStore._();

  static String? _stagedCode;

  /// Synchronous staging for [GoRouter.redirect] before prefs write completes.
  static void stage(String inviteCode) {
    final code = inviteCode.trim();
    if (code.isEmpty) return;
    _stagedCode = code;
  }

  static Future<void> save(String inviteCode) async {
    final code = inviteCode.trim();
    if (code.isEmpty) return;
    stage(code);
    try {
      await ServiceLocator.instance.sharedPrefs.saveString(
        StorageKeys.pendingProjectInviteCode,
        code,
      );
    } catch (_) {
      // In-memory [stage] still applies when prefs are not ready (e.g. tests).
    }
  }

  static Future<String?> read() async {
    final staged = _stagedCode?.trim();
    if (staged != null && staged.isNotEmpty) return staged;

    final code = await ServiceLocator.instance.sharedPrefs.getString(
      StorageKeys.pendingProjectInviteCode,
    );
    final trimmed = code?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    _stagedCode = trimmed;
    return trimmed;
  }

  static Future<void> clear() async {
    _stagedCode = null;
    await ServiceLocator.instance.sharedPrefs.remove(
      StorageKeys.pendingProjectInviteCode,
    );
  }

  /// Returns the stored code and clears it (one-shot after auth routing).
  static Future<String?> consume() async {
    final code = await read();
    if (code == null) return null;
    await clear();
    return code;
  }
}
