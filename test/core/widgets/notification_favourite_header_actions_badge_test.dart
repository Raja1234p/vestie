import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vestie/core/widgets/common/notification_favourite_header_actions.dart';
import 'package:vestie/features/notifications/domain/usecases/notifications_usecases.dart';
import 'package:vestie/features/notifications/presentation/cubit/notification_unread_cubit.dart';
import 'package:vestie/features/notifications/presentation/widgets/notification_unread_badge.dart';

class _MockListNotificationsUseCase extends Mock
    implements ListNotificationsUseCase {}

Future<void> _pumpHeader(
  WidgetTester tester, {
  required NotificationUnreadCubit cubit,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (_, _) => MaterialApp(
        home: BlocProvider<NotificationUnreadCubit>.value(
          value: cubit,
          child: const Scaffold(
            body: NotificationFavouriteHeaderActions(vffShowcaseKey: null),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  late _MockListNotificationsUseCase listNotifications;

  setUp(() {
    listNotifications = _MockListNotificationsUseCase();
  });

  group('NotificationFavouriteHeaderActions unread badge', () {
    testWidgets('shows no count pill when unread is zero', (tester) async {
      final cubit = NotificationUnreadCubit(
        listNotificationsUseCase: listNotifications,
      );
      addTearDown(cubit.close);

      await _pumpHeader(tester, cubit: cubit);

      expect(find.byType(NotificationUnreadBadge), findsNothing);
    });

    testWidgets('shows count pill when unread is greater than zero', (
      tester,
    ) async {
      final cubit = NotificationUnreadCubit(
        listNotificationsUseCase: listNotifications,
      );
      addTearDown(cubit.close);

      cubit.setCount(5);
      await _pumpHeader(tester, cubit: cubit);

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('updates badge when unread count decreases', (tester) async {
      final cubit = NotificationUnreadCubit(
        listNotificationsUseCase: listNotifications,
      );
      addTearDown(cubit.close);

      for (final count in [3, 2, 1]) {
        cubit.setCount(count);
        await _pumpHeader(tester, cubit: cubit);
        expect(find.text('$count'), findsOneWidget);
      }

      cubit.setCount(0);
      await _pumpHeader(tester, cubit: cubit);
      expect(find.byType(NotificationUnreadBadge), findsNothing);
    });
  });
}
