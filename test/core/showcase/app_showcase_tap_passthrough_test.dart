import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/showcase/app_showcase.dart';
import 'package:vestie/core/widgets/common/app_toggle_tab_bar.dart';
import 'package:vestie/core/widgets/common/notification_favourite_header_actions.dart';
import 'package:vestie/features/notifications/domain/usecases/notifications_usecases.dart';
import 'package:vestie/features/notifications/presentation/cubit/notification_unread_cubit.dart';

class _MockListNotificationsUseCase extends Mock
    implements ListNotificationsUseCase {}

Widget _wrapNotificationHeader(Widget child) {
  final listNotifications = _MockListNotificationsUseCase();
  return BlocProvider<NotificationUnreadCubit>(
    create: (_) => NotificationUnreadCubit(
      listNotificationsUseCase: listNotifications,
    ),
    child: child,
  );
}

Future<void> _pumpPhoneApp(
  WidgetTester tester, {
  Widget Function()? home,
  RouterConfig<Object>? router,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MediaQuery(
      data: const MediaQueryData(size: Size(390, 844)),
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        useInheritedMediaQuery: true,
        builder: (_, _) => router == null
            ? MaterialApp(home: home!())
            : MaterialApp.router(routerConfig: router),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('Showcase wrappers do not steal taps when the tour is idle', () {
    testWidgets('wrapIf(enabled: false) is a passthrough', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppShowcase.wrapIf(
              enabled: false,
              key: GlobalKey(),
              title: 't',
              description: 'd',
              child: TextButton(
                onPressed: () => taps++,
                child: const Text('Go'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Go'));
      expect(taps, 1);
    });

    testWidgets('idle highlight still delivers child taps', (tester) async {
      AppShowcase.register();
      addTearDown(AppShowcase.unregister);

      var taps = 0;
      await _pumpPhoneApp(
        tester,
        home: () => Scaffold(
          body: AppShowcase.highlight(
            key: AppShowcaseKeys.leaderContribute,
            title: 't',
            description: 'd',
            child: TextButton(
              onPressed: () => taps++,
              child: const Text('Contribute'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Contribute'));
      expect(taps, 1);
      expect(find.byType(Showcase), findsOneWidget);
    });

    testWidgets('nav-style Showcase wrap still reports onTap', (tester) async {
      AppShowcase.register();
      addTearDown(AppShowcase.unregister);

      var tapped = -1;
      await _pumpPhoneApp(
        tester,
        home: () => Scaffold(
          body: Row(
            children: [
              for (var i = 0; i < 5; i++)
                Expanded(
                  child: AppShowcase.highlight(
                    key: AppShowcaseKeys.dashboardTour[i],
                    title: 't$i',
                    description: 'd',
                    child: GestureDetector(
                      onTap: () => tapped = i,
                      behavior: HitTestBehavior.opaque,
                      child: SizedBox(
                        height: 48,
                        child: Center(child: Text('tab$i')),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );

      await tester.tap(find.text('tab3'));
      expect(tapped, 3);
      await tester.tap(find.text('tab0'));
      expect(tapped, 0);
      await tester.tap(find.text('tab2'));
      expect(tapped, 2);
      await tester.tap(find.text('tab1'));
      expect(tapped, 1);
      await tester.tap(find.text('tab4'));
      expect(tapped, 4);
    });

    testWidgets('Home VFF key and Discover header can coexist', (tester) async {
      AppShowcase.register();
      addTearDown(AppShowcase.unregister);

      await _pumpPhoneApp(
        tester,
        home: () => Scaffold(
          body: _wrapNotificationHeader(
            const Row(
              children: [
                NotificationFavouriteHeaderActions(vffShowcaseKey: null),
                _HomeVffActions(),
              ],
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(SvgPicture), findsNWidgets(4));
    });

    testWidgets('header VFF and notifications still navigate', (tester) async {
      AppShowcase.register();
      addTearDown(AppShowcase.unregister);

      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => Scaffold(
              body: _wrapNotificationHeader(
                const NotificationFavouriteHeaderActions(vffShowcaseKey: null),
              ),
            ),
          ),
          GoRoute(
            path: AppRoutes.userVffMain,
            builder: (_, _) => const Text('vff-hub'),
          ),
          GoRoute(
            path: AppRoutes.notifications,
            builder: (_, _) => const Text('notifications'),
          ),
        ],
      );
      addTearDown(router.dispose);

      await _pumpPhoneApp(tester, router: router);

      await tester.tap(find.byType(SvgPicture).first);
      await tester.pumpAndSettle();
      expect(find.text('notifications'), findsOneWidget);

      router.go('/');
      await tester.pumpAndSettle();

      await tester.tap(find.byType(SvgPicture).last);
      await tester.pumpAndSettle();
      expect(find.text('vff-hub'), findsOneWidget);
    });

    testWidgets('wrapped header VFF still opens the hub', (tester) async {
      AppShowcase.register();
      addTearDown(AppShowcase.unregister);

      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => Scaffold(
              body: _wrapNotificationHeader(const _HomeVffActions()),
            ),
          ),
          GoRoute(
            path: AppRoutes.userVffMain,
            builder: (_, _) => const Text('vff-hub'),
          ),
          GoRoute(
            path: AppRoutes.notifications,
            builder: (_, _) => const Text('notifications'),
          ),
        ],
      );
      addTearDown(router.dispose);

      await _pumpPhoneApp(tester, router: router);

      await tester.tap(find.byType(SvgPicture).last);
      await tester.pumpAndSettle();
      expect(find.text('vff-hub'), findsOneWidget);
    });

    testWidgets('idle VFF hub tab wrap still switches tabs', (tester) async {
      AppShowcase.register();
      addTearDown(AppShowcase.unregister);

      var index = 0;
      await _pumpPhoneApp(
        tester,
        home: () => Scaffold(
          body: AppShowcase.highlight(
            key: AppShowcaseKeys.vffHubTabs,
            title: AppStrings.showcaseVffHubTitle,
            description: AppStrings.showcaseVffHubBody,
            child: AppToggleTabBar(
              tabs: const [
                AppStrings.userVffTabMyVffs,
                AppStrings.userVffTabRequests,
              ],
              activeIndex: index,
              onTabSelected: (i) => index = i,
            ),
          ),
        ),
      );
      await tester.tap(find.text(AppStrings.userVffTabRequests));
      expect(index, 1);
    });
  });
}

class _HomeVffActions extends StatelessWidget {
  const _HomeVffActions();

  @override
  Widget build(BuildContext context) {
    return NotificationFavouriteHeaderActions(
      vffShowcaseKey: AppShowcaseKeys.headerVff,
    );
  }
}
