import '../constants/storage_keys.dart';
import '../di/service_locator.dart';

/// One-time ShowcaseView tours (overlay only — does not change app behavior).
enum AppShowcaseTour { dashboard, leaderDetail, vffHub }

/// One-time ShowcaseView flags — independent of the pre-login onboarding carousel.
abstract final class ShowcasePrefs {
  static Future<bool> hasCompleted(AppShowcaseTour tour) =>
      ServiceLocator.instance.sharedPrefs.getBool(_key(tour));

  static Future<void> markCompleted(AppShowcaseTour tour) =>
      ServiceLocator.instance.sharedPrefs.saveBool(_key(tour), true);

  static String _key(AppShowcaseTour tour) => switch (tour) {
        AppShowcaseTour.dashboard => StorageKeys.showcaseDashboardDone,
        AppShowcaseTour.leaderDetail => StorageKeys.showcaseLeaderDetailDone,
        AppShowcaseTour.vffHub => StorageKeys.showcaseVffHubDone,
      };
}
