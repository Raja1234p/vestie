import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vestie/core/error/failures.dart';
import 'package:vestie/core/services/notifications/vff_pending_refresh.dart';
import 'package:vestie/user/features/vff/domain/entities/vff_inbox_entity.dart';
import 'package:vestie/user/features/vff/domain/entities/vff_enums.dart';
import 'package:vestie/user/features/vff/domain/usecases/vff_usecases.dart';
import 'package:vestie/user/features/vff/presentation/cubit/vff_pending_cubit.dart';
import 'package:vestie/core/domain/entities/pagination_info.dart';

class _MockGetVffReceivedInboxUseCase extends Mock
    implements GetVffReceivedInboxUseCase {}

VffReceivedInboxEntity _emptyInbox() => const VffReceivedInboxEntity(
      vffRequestsPagination: PaginationInfo(
        page: 1,
        pageSize: 1,
        totalCount: 0,
        totalPages: 0,
      ),
      projectInvitesPagination: PaginationInfo(
        page: 1,
        pageSize: 1,
        totalCount: 0,
        totalPages: 0,
      ),
    );

VffReceivedInboxEntity _inboxWithRequest() => VffReceivedInboxEntity(
      vffRequests: [
        const VffInboxRequestEntity(
          requestId: 'r1',
          projectId: 'p1',
          projectName: 'Beach',
          senderUserId: 'u1',
          senderName: 'Alice',
          status: VffRequestStatus.pending,
        ),
      ],
      vffRequestsPagination: const PaginationInfo(
        page: 1,
        pageSize: 1,
        totalCount: 1,
        totalPages: 1,
      ),
      projectInvitesPagination: const PaginationInfo(
        page: 1,
        pageSize: 1,
        totalCount: 0,
        totalPages: 0,
      ),
    );

void main() {
  late _MockGetVffReceivedInboxUseCase getInbox;

  setUp(() {
    getInbox = _MockGetVffReceivedInboxUseCase();
  });

  VffPendingCubit createCubit() =>
      VffPendingCubit(getVffReceivedInboxUseCase: getInbox);

  group('VffPendingCubit', () {
    test('starts with hasPending false', () {
      final cubit = createCubit();
      addTearDown(cubit.close);
      expect(cubit.state.hasPending, false);
    });

    test('refresh sets hasPending true when inbox has requests', () async {
      when(
        () => getInbox(vffRequestsPageSize: 1, projectInvitesPageSize: 1),
      ).thenAnswer((_) async => Right(_inboxWithRequest()));

      final cubit = createCubit();
      addTearDown(cubit.close);

      await cubit.refresh();

      expect(cubit.state.hasPending, true);
    });

    test('refresh sets hasPending false when inbox is empty', () async {
      when(
        () => getInbox(vffRequestsPageSize: 1, projectInvitesPageSize: 1),
      ).thenAnswer((_) async => Right(_emptyInbox()));

      final cubit = createCubit();
      addTearDown(cubit.close);

      cubit.setHasPending(true);
      await cubit.refresh();

      expect(cubit.state.hasPending, false);
    });

    test('refresh keeps last value on API failure', () async {
      when(
        () => getInbox(vffRequestsPageSize: 1, projectInvitesPageSize: 1),
      ).thenAnswer((_) async => const Left(NetworkFailure()));

      final cubit = createCubit();
      addTearDown(cubit.close);

      cubit.setHasPending(true);
      await cubit.refresh();

      expect(cubit.state.hasPending, true);
    });

    test('setHasPending is a no-op when value unchanged', () {
      final cubit = createCubit();
      addTearDown(cubit.close);

      cubit.setHasPending(false);
      expect(cubit.state.hasPending, false);

      cubit.setHasPending(true);
      cubit.setHasPending(true);
      expect(cubit.state.hasPending, true);
    });

    test('reset clears hasPending', () {
      final cubit = createCubit();
      addTearDown(cubit.close);

      cubit.setHasPending(true);
      cubit.reset();

      expect(cubit.state.hasPending, false);
    });

    test('FCM bridge notifyPending sets dot immediately', () {
      final cubit = createCubit();
      addTearDown(cubit.close);

      VffPendingRefresh.notifyPending();

      expect(cubit.state.hasPending, true);
    });

    test('FCM bridge notifyClear clears dot', () {
      final cubit = createCubit();
      addTearDown(cubit.close);

      VffPendingRefresh.notifyPending();
      expect(cubit.state.hasPending, true);

      VffPendingRefresh.notifyClear();
      expect(cubit.state.hasPending, false);
    });

    test('bridge requestRefresh probes API', () async {
      when(
        () => getInbox(vffRequestsPageSize: 1, projectInvitesPageSize: 1),
      ).thenAnswer((_) async => Right(_inboxWithRequest()));

      final cubit = createCubit();
      addTearDown(cubit.close);

      await VffPendingRefresh.requestRefresh();

      expect(cubit.state.hasPending, true);
    });
  });
}
