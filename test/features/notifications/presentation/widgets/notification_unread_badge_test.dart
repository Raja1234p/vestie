import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/features/notifications/presentation/widgets/notification_unread_badge.dart';

Future<void> _pumpBadge(WidgetTester tester, Widget badge) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (_, _) => MaterialApp(home: Scaffold(body: badge)),
    ),
  );
}

void main() {
  group('NotificationUnreadBadge', () {
    testWidgets('hides when count is zero', (tester) async {
      await _pumpBadge(
        tester,
        const NotificationUnreadBadge(count: 0),
      );

      expect(find.text('0'), findsNothing);
      expect(find.text('99+'), findsNothing);
    });

    testWidgets('shows count for header style', (tester) async {
      await _pumpBadge(
        tester,
        const NotificationUnreadBadge(count: 7),
      );

      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('caps display at 99+', (tester) async {
      await _pumpBadge(
        tester,
        const NotificationUnreadBadge(count: 120),
      );

      expect(find.text('99+'), findsOneWidget);
    });

    testWidgets('icon overlay style shows compact count', (tester) async {
      await _pumpBadge(
        tester,
        const NotificationUnreadBadge(
          count: 4,
          style: NotificationUnreadBadgeStyle.iconOverlay,
        ),
      );

      expect(find.text('4'), findsOneWidget);
    });
  });
}
