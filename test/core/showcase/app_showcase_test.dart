import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/constants/storage_keys.dart';
import 'package:vestie/core/showcase/app_showcase.dart';
import 'package:vestie/core/storage/showcase_prefs.dart';
import 'package:vestie/user/features/home/presentation/widgets/home_empty_view.dart';

void main() {
  group('AppShowcaseKeys', () {
    test('dashboard tour visits all five tabs then VFF', () {
      expect(AppShowcaseKeys.dashboardTour, [
        AppShowcaseKeys.navHome,
        AppShowcaseKeys.navDiscover,
        AppShowcaseKeys.navCreate,
        AppShowcaseKeys.navWallet,
        AppShowcaseKeys.navProfile,
        AppShowcaseKeys.headerVff,
      ]);
    });

    test('leader tour covers join requests, contribute, and menu', () {
      expect(AppShowcaseKeys.leaderDetailTour, [
        AppShowcaseKeys.leaderJoinRequests,
        AppShowcaseKeys.leaderContribute,
        AppShowcaseKeys.leaderMenu,
      ]);
    });

    test('VFF hub tour highlights the My VFFs / Requests tabs', () {
      expect(AppShowcaseKeys.vffHubTour, [AppShowcaseKeys.vffHubTabs]);
    });
  });

  group('showcase copy', () {
    test('uses user-friendly titles without empty bodies', () {
      expect(AppStrings.showcaseDashboardCreateTitle, isNotEmpty);
      expect(AppStrings.showcaseDashboardCreateBody, contains('leader'));
      expect(AppStrings.showcaseLeaderJoinBody.toLowerCase(), contains('accept'));
      expect(AppStrings.showcaseLeaderMenuBody, contains('Mark successful'));
      expect(AppStrings.showcaseLeaderMenuBody, contains('Cancel'));
      expect(AppStrings.showcaseVffHubBody.toLowerCase(), contains('requests'));
    });
  });

  group('ShowcasePrefs keys', () {
    test('each tour has a dedicated prefs key', () {
      expect(StorageKeys.showcaseDashboardDone, 'showcase_dashboard_done');
      expect(
        StorageKeys.showcaseLeaderDetailDone,
        'showcase_leader_detail_done',
      );
      expect(StorageKeys.showcaseVffHubDone, 'showcase_vff_hub_done');
      expect(AppShowcaseTour.values, hasLength(3));
    });
  });

  group('returning-user policy (no overlay on existing accounts)', () {
    test('suppresses tours when the user already has groups', () {
      expect(
        AppShowcase.shouldSuppressForReturningUser(
          hasProjects: true,
          dashboardTourAlreadyDone: false,
        ),
        isTrue,
      );
    });

    test('does not suppress empty-home first launch', () {
      expect(
        AppShowcase.shouldSuppressForReturningUser(
          hasProjects: false,
          dashboardTourAlreadyDone: false,
        ),
        isFalse,
      );
    });

    test('does not re-suppress after dashboard tour already ran', () {
      expect(
        AppShowcase.shouldSuppressForReturningUser(
          hasProjects: true,
          dashboardTourAlreadyDone: true,
        ),
        isFalse,
      );
    });

    test('leader and VFF tours wait until dashboard tour is done', () {
      expect(
        AppShowcase.canStartFollowUpTour(dashboardTourAlreadyDone: false),
        isFalse,
      );
      expect(
        AppShowcase.canStartFollowUpTour(dashboardTourAlreadyDone: true),
        isTrue,
      );
    });
  });

  group('wrappers do not replace member widgets', () {
    test('wrapIf(enabled: false) returns the original child instance', () {
      const child = SizedBox(width: 1, height: 1);
      final wrapped = AppShowcase.wrapIf(
        enabled: false,
        key: GlobalKey(),
        title: 't',
        description: 'd',
        child: child,
      );
      expect(identical(wrapped, child), isTrue);
    });

    test('Discover empty VFF button does not share the Home tour key', () {
      expect(HomeEmptyView.forDiscover().vffShowcaseKey, isNull);
      expect(
        HomeEmptyView.forHome(onCreateProject: () {}).vffShowcaseKey,
        same(AppShowcaseKeys.headerVff),
      );
    });
  });
}
