import '../constants/storage_keys.dart';
import '../di/service_locator.dart';

/// Persists whether the user has completed the first-run onboarding carousel.
abstract final class OnboardingPrefs {
  static Future<bool> hasCompleted() =>
      ServiceLocator.instance.sharedPrefs.getBool(StorageKeys.hasSeenOnboarding);

  static Future<void> markCompleted() => ServiceLocator.instance.sharedPrefs
      .saveBool(StorageKeys.hasSeenOnboarding, true);
}
