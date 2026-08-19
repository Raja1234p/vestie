import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vestie/core/widgets/common/notification_favourite_header_actions.dart';
import 'package:vestie/features/notifications/domain/usecases/notifications_usecases.dart';
import 'package:vestie/features/notifications/presentation/cubit/notification_unread_cubit.dart';
import 'package:vestie/user/features/vff/domain/usecases/vff_usecases.dart';
import 'package:vestie/user/features/vff/presentation/cubit/vff_pending_cubit.dart';

class _MockListNotificationsUseCase extends Mock
    implements ListNotificationsUseCase {}

class _MockGetVffReceivedInboxUseCase extends Mock
    implements GetVffReceivedInboxUseCase {}

late NotificationUnreadCubit _notifCubit;

Future<void> _pump(
  WidgetTester tester, {
  required VffPendingCubit vffCubit,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  _notifCubit = NotificationUnreadCubit(
    listNotificationsUseCase: _MockListNotificationsUseCase(),
  );
  addTearDown(_notifCubit.close);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (_, _) => MultiBlocProvider(
        providers: [
          BlocProvider<NotificationUnreadCubit>.value(value: _notifCubit),
          BlocProvider<VffPendingCubit>.value(value: vffCubit),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: NotificationFavouriteHeaderActions(vffShowcaseKey: null),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

bool _hasDot(WidgetTester tester) =>
    find.byKey(const Key('vff_pending_dot')).evaluate().isNotEmpty;

void main() {
  late _MockGetVffReceivedInboxUseCase getInbox;

  setUp(() {
    getInbox = _MockGetVffReceivedInboxUseCase();
  });

  group('VFF pending dot badge on header', () {
    testWidgets('no dot when hasPending is false', (tester) async {
      final cubit = VffPendingCubit(getVffReceivedInboxUseCase: getInbox);
      addTearDown(cubit.close);

      await _pump(tester, vffCubit: cubit);

      expect(_hasDot(tester), false);
    });

    testWidgets('dot appears when hasPending is true at initial build', (
      tester,
    ) async {
      final cubit = VffPendingCubit(getVffReceivedInboxUseCase: getInbox);
      addTearDown(cubit.close);

      cubit.setHasPending(true);
      await _pump(tester, vffCubit: cubit);

      expect(_hasDot(tester), true);
    });

    testWidgets('no dot when hasPending resets from true to false', (
      tester,
    ) async {
      final cubit = VffPendingCubit(getVffReceivedInboxUseCase: getInbox);
      addTearDown(cubit.close);

      cubit.setHasPending(true);
      await _pump(tester, vffCubit: cubit);
      expect(_hasDot(tester), true);

      cubit.setHasPending(false);
      // Repump whole widget so BlocProvider.value rebuilds with updated state
      await _pump(tester, vffCubit: cubit);
      expect(_hasDot(tester), false);
    });
  });
}
