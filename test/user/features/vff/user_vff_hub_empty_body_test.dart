import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/user/features/vff/presentation/widgets/user_vff_hub_empty_body.dart';

const _hostKey = Key('empty_host');

Future<void> _pumpEmptyHost(
  WidgetTester tester, {
  required Widget child,
  Size hostSize = const Size(390, 600),
}) async {
  await tester.binding.setSurfaceSize(hostSize);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (_, __) => MaterialApp(
        home: Scaffold(
          body: SizedBox(
            key: _hostKey,
            width: hostSize.width,
            height: hostSize.height,
            child: child,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Rect _rectOf(WidgetTester tester, Finder finder) {
  return tester.getRect(finder);
}

Finder get _contentColumn => find.descendant(
      of: find.byType(Center),
      matching: find.byType(Column),
    );

void main() {
  group('UserVffHubEmptyBody layout', () {
    testWidgets('fills host with expand and centers child', (tester) async {
      await _pumpEmptyHost(
        tester,
        child: const UserVffHubEmptyBody(
          message: AppStrings.userVffEmptyRequests,
        ),
      );

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is SizedBox &&
              widget.width == double.infinity &&
              widget.height == double.infinity,
        ),
        findsOneWidget,
      );
      expect(find.byType(Center), findsOneWidget);
    });

    testWidgets('centers content vertically and horizontally in host',
        (tester) async {
      await _pumpEmptyHost(
        tester,
        child: const UserVffHubEmptyBody(
          message: AppStrings.userVffEmptyRequests,
        ),
      );

      final hostRect = _rectOf(tester, find.byKey(_hostKey));
      final contentRect = _rectOf(tester, _contentColumn);

      expect(contentRect.center.dx, closeTo(hostRect.center.dx, 2));
      expect(contentRect.center.dy, closeTo(hostRect.center.dy, 2));
    });

    testWidgets('centers content when wrapped in full-list empty inset',
        (tester) async {
      await _pumpEmptyHost(
        tester,
        child: Padding(
          padding: AppDimens.vffInboxFullListEmptyInset,
          child: const UserVffHubEmptyBody(
            message: AppStrings.userVffEmptyRequests,
          ),
        ),
      );

      final hostRect = _rectOf(tester, find.byKey(_hostKey));
      final contentRect = _rectOf(tester, _contentColumn);

      expect(contentRect.center.dx, closeTo(hostRect.center.dx, 2));
      expect(contentRect.center.dy, closeTo(hostRect.center.dy, 2));
    });

    testWidgets('uses 150x150 default illustration', (tester) async {
      await _pumpEmptyHost(
        tester,
        child: const UserVffHubEmptyBody(
          message: AppStrings.userVffEmptyRequests,
        ),
      );

      final image = tester.widget<Image>(find.byType(Image));
      expect(image.image, const AssetImage(AppAssets.inviteProjectHero));
      expect(image.width, AppDimens.vffEmptyStateIllustration);
      expect(image.height, AppDimens.vffEmptyStateIllustration);
    });

    testWidgets('shows message and optional subtitle', (tester) async {
      await _pumpEmptyHost(
        tester,
        hostSize: const Size(390, 720),
        child: const UserVffHubEmptyBody(
          message: AppStrings.userVffEmptyRequests,
          subtitle: 'Subtitle copy',
        ),
      );

      expect(find.text(AppStrings.userVffEmptyRequests), findsOneWidget);
      expect(find.text('Subtitle copy'), findsOneWidget);
    });
  });

  group('VFF full-list empty inset', () {
    testWidgets('uses horizontal-only padding so empty state can center',
        (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (_, __) => const SizedBox.shrink(),
        ),
      );

      final inset = AppDimens.vffInboxFullListEmptyInset;
      expect(inset.top, 0);
      expect(inset.bottom, 0);
      expect(inset.left, greaterThan(0));
      expect(inset.right, greaterThan(0));
    });
  });
}
