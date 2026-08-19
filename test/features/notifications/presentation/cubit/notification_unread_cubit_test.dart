import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vestie/core/error/failures.dart';
import 'package:vestie/core/services/notifications/notification_unread_refresh.dart';
import 'package:vestie/features/notifications/domain/entities/app_notification_entity.dart';
import 'package:vestie/features/notifications/domain/usecases/notifications_usecases.dart';
import 'package:vestie/features/notifications/presentation/cubit/notification_unread_cubit.dart';

class _MockListNotificationsUseCase extends Mock
    implements ListNotificationsUseCase {}

void main() {
  late _MockListNotificationsUseCase listNotifications;

  const pageWithUnread = NotificationsPageEntity(
    notifications: [],
    unreadCount: 3,
    page: 1,
    pageSize: 1,
    totalCount: 3,
  );

  setUp(() {
    listNotifications = _MockListNotificationsUseCase();
  });

  NotificationUnreadCubit createCubit() => NotificationUnreadCubit(
        listNotificationsUseCase: listNotifications,
      );

  group('NotificationUnreadCubit', () {
    test('starts with zero unread', () {
      final cubit = createCubit();
      addTearDown(cubit.close);

      expect(cubit.state.unreadCount, 0);
    });

    test('refresh updates unreadCount from GET /notifications probe', () async {
      when(
        () => listNotifications(page: 1, pageSize: 1),
      ).thenAnswer((_) async => const Right(pageWithUnread));

      final cubit = createCubit();
      addTearDown(cubit.close);

      await cubit.refresh();

      expect(cubit.state.unreadCount, 3);
      verify(() => listNotifications(page: 1, pageSize: 1)).called(1);
    });

    test('refresh keeps last count on failure', () async {
      when(
        () => listNotifications(page: 1, pageSize: 1),
      ).thenAnswer((_) async => const Left(NetworkFailure()));

      final cubit = createCubit();
      addTearDown(cubit.close);

      cubit.setCount(5);
      await cubit.refresh();

      expect(cubit.state.unreadCount, 5);
    });

    test('setCount ignores negative values and no-op when unchanged', () {
      final cubit = createCubit();
      addTearDown(cubit.close);

      cubit.setCount(-1);
      expect(cubit.state.unreadCount, 0);

      cubit.setCount(2);
      cubit.setCount(2);
      expect(cubit.state.unreadCount, 2);
    });

    test('reset clears unread count', () {
      final cubit = createCubit();
      addTearDown(cubit.close);

      cubit.setCount(4);
      cubit.reset();

      expect(cubit.state.unreadCount, 0);
    });

    test('registers refresh hook for FCM foreground refresh', () async {
      when(
        () => listNotifications(page: 1, pageSize: 1),
      ).thenAnswer((_) async => const Right(pageWithUnread));

      final cubit = createCubit();
      addTearDown(cubit.close);

      await NotificationUnreadRefresh.requestRefresh();

      expect(cubit.state.unreadCount, 3);
    });

    test('setCount reflects sequential mark-read decrements', () {
      final cubit = createCubit();
      addTearDown(cubit.close);

      cubit.setCount(3);
      expect(cubit.state.unreadCount, 3);

      cubit.setCount(2);
      expect(cubit.state.unreadCount, 2);

      cubit.setCount(1);
      expect(cubit.state.unreadCount, 1);

      cubit.setCount(0);
      expect(cubit.state.unreadCount, 0);
    });

    test('refresh replaces count when server unread decreases', () async {
      when(
        () => listNotifications(page: 1, pageSize: 1),
      ).thenAnswer(
        (_) async => const Right(
          NotificationsPageEntity(
            notifications: [],
            unreadCount: 1,
            page: 1,
            pageSize: 1,
            totalCount: 1,
          ),
        ),
      );

      final cubit = createCubit();
      addTearDown(cubit.close);

      cubit.setCount(5);
      await cubit.refresh();

      expect(cubit.state.unreadCount, 1);
    });
  });
}
