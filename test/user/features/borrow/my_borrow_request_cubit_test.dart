import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vestie/app/router/route_args/project_detail_flow_args.dart';
import 'package:vestie/core/error/failures.dart';
import 'package:vestie/features/project_detail/domain/entities/borrow_request_entity.dart';
import 'package:vestie/user/features/borrow/domain/entities/my_borrow_screen_entity.dart';
import 'package:vestie/user/features/borrow/domain/usecases/cancel_borrow_request_use_case.dart';
import 'package:vestie/user/features/borrow/domain/usecases/get_active_repay_summary_use_case.dart';
import 'package:vestie/user/features/borrow/domain/usecases/get_borrow_repay_summary_use_case.dart';
import 'package:vestie/user/features/borrow/domain/usecases/get_my_borrow_screen_use_case.dart';
import 'package:vestie/user/features/borrow/presentation/cubit/my_borrow_request_cubit.dart';

class _MockGetMyBorrowScreenUseCase extends Mock
    implements GetMyBorrowScreenUseCase {}

class _MockGetActiveRepaySummaryUseCase extends Mock
    implements GetActiveRepaySummaryUseCase {}

class _MockGetBorrowRepaySummaryUseCase extends Mock
    implements GetBorrowRepaySummaryUseCase {}

class _MockCancelBorrowRequestUseCase extends Mock
    implements CancelBorrowRequestUseCase {}

void main() {
  late _MockGetMyBorrowScreenUseCase getScreen;
  late _MockGetActiveRepaySummaryUseCase getActiveRepay;
  late _MockGetBorrowRepaySummaryUseCase getRepaySummary;
  late _MockCancelBorrowRequestUseCase cancelRequest;

  const pendingRequest = BorrowRequestEntity(
    id: 'req-pending',
    initials: 'AB',
    memberName: 'Alex',
    loanType: 'Emergency',
    requestedAmount: 200,
    upvotes: 1,
    downvotes: 0,
    status: 'Pending',
  );

  setUp(() {
    getScreen = _MockGetMyBorrowScreenUseCase();
    getActiveRepay = _MockGetActiveRepaySummaryUseCase();
    getRepaySummary = _MockGetBorrowRepaySummaryUseCase();
    cancelRequest = _MockCancelBorrowRequestUseCase();

    when(
      () => getActiveRepay(projectId: any(named: 'projectId')),
    ).thenAnswer((_) async => const Left(ServerFailure()));
  });

  MyBorrowRequestCubit createCubit() => MyBorrowRequestCubit(
    projectId: 'proj-1',
    getMyBorrowScreenUseCase: getScreen,
    getActiveRepaySummaryUseCase: getActiveRepay,
    getBorrowRepaySummaryUseCase: getRepaySummary,
    cancelBorrowRequestUseCase: cancelRequest,
  );

  group('MyBorrowRequestCubit', () {
    test('loadFailed when initial load fails with no cached data', () async {
      when(
        () => getScreen(projectId: any(named: 'projectId')),
      ).thenAnswer((_) async => const Left(NetworkFailure()));

      final cubit = createCubit();
      addTearDown(cubit.close);

      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.loadFailed, isTrue);
      expect(cubit.state.loading, isFalse);
    });

    test('cancelActiveRequest returns false on API failure', () async {
      when(
        () => getScreen(projectId: any(named: 'projectId')),
      ).thenAnswer(
        (_) async => const Right(
          MyBorrowScreenEntity(activeRequest: pendingRequest),
        ),
      );
      when(
        () => cancelRequest(
          projectId: any(named: 'projectId'),
          borrowRequestId: any(named: 'borrowRequestId'),
        ),
      ).thenAnswer((_) async => const Left(ServerFailure('Cancel failed')));

      final cubit = createCubit();
      addTearDown(cubit.close);
      await Future<void>.delayed(Duration.zero);

      final ok = await cubit.cancelActiveRequest();

      expect(ok, isFalse);
      expect(cubit.state.cancelling, isFalse);
      expect(cubit.state.errorMessage, isNotNull);
      expect(cubit.state.activeRequest, isNotNull);
    });

    test('cancelActiveRequest clears pending request on success', () async {
      when(
        () => getScreen(projectId: any(named: 'projectId')),
      ).thenAnswer(
        (_) async => const Right(
          MyBorrowScreenEntity(activeRequest: pendingRequest),
        ),
      );
      when(
        () => cancelRequest(
          projectId: any(named: 'projectId'),
          borrowRequestId: any(named: 'borrowRequestId'),
        ),
      ).thenAnswer((_) async => const Right(null));

      final cubit = createCubit();
      addTearDown(cubit.close);
      await Future<void>.delayed(Duration.zero);

      final ok = await cubit.cancelActiveRequest();

      expect(ok, isTrue);
      expect(cubit.state.activeRequest, isNull);
      expect(cubit.state.cancelling, isFalse);
    });
  });

  group('MyBorrowRequestCubit.resolveRepayableRequestId', () {
    test('prefers repayable current request', () {
      const current = BorrowRequestEntity(
        id: 'req-current',
        initials: 'AB',
        memberName: 'Alex',
        loanType: 'Emergency',
        requestedAmount: 200,
        upvotes: 0,
        downvotes: 0,
        status: 'Disbursed',
      );

      final id = MyBorrowRequestCubit.resolveRepayableRequestId(
        current: current,
        history: const [],
      );

      expect(id, 'req-current');
    });

    test('falls back to repayable history row when current is null', () {
      const history = [
        MyBorrowHistoryEntry(
          id: 'req-history',
          amount: 150,
          dateLabel: 'May 1',
          isApproved: true,
          status: 'Disbursed',
        ),
      ];

      final id = MyBorrowRequestCubit.resolveRepayableRequestId(
        current: null,
        history: history,
      );

      expect(id, 'req-history');
    });
  });
}
