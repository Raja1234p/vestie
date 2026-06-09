import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vestie/app/router/route_args/project_wallet_flow_args.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/error/failures.dart';
import 'package:vestie/user/features/borrow/domain/entities/borrow_terms_entity.dart';
import 'package:vestie/user/features/borrow/domain/repositories/borrow_repository.dart';
import 'package:vestie/user/features/borrow/domain/usecases/create_borrow_request_use_case.dart';
import 'package:vestie/user/features/borrow/domain/usecases/get_borrow_terms_use_case.dart';
import 'package:vestie/user/features/borrow/presentation/cubit/borrow_cubit.dart';

class _MockGetBorrowTermsUseCase extends Mock implements GetBorrowTermsUseCase {}

class _MockCreateBorrowRequestUseCase extends Mock
    implements CreateBorrowRequestUseCase {}

void main() {
  late _MockGetBorrowTermsUseCase getTerms;
  late _MockCreateBorrowRequestUseCase createRequest;

  const args = ProjectWalletFlowArgs(
    projectId: 'proj-1',
    projectName: 'Europe 2025',
    borrowLimit: 500,
    borrowDueByLabel: 'Jun 1, 2026',
  );

  const terms = BorrowTermsEntity(
    amount: 100,
    currency: 'USD',
    dueByDisplay: 'Jun 1, 2026',
    penaltyPercentage: 10,
    penaltyIfMissedDisplay: '10%',
    penaltyAppliesDisplay: 'One time',
    agreementText: 'Agree to repay',
    canBorrow: true,
  );

  const borrowResult = BorrowRequestResult(
    id: 'req-1',
    projectId: 'proj-1',
    requestedAmount: 100,
    currency: 'USD',
    status: 'Pending',
    dueAtUtc: '2026-06-01T00:00:00Z',
  );

  BorrowCubit createCubit() => BorrowCubit(
    args,
    getBorrowTermsUseCase: getTerms,
    createBorrowRequestUseCase: createRequest,
  );

  setUp(() {
    getTerms = _MockGetBorrowTermsUseCase();
    createRequest = _MockCreateBorrowRequestUseCase();
  });

  tearDown(() async {
    // Cubits created per test are closed in each test.
  });

  group('BorrowCubit', () {
    test('toConfirm sets idempotency key when terms allow borrow', () async {
      when(
        () => getTerms(projectId: any(named: 'projectId'), amount: any(named: 'amount')),
      ).thenAnswer((_) async => const Right(terms));

      final cubit = createCubit();
      addTearDown(cubit.close);

      cubit.setAmountDigits('10000');
      await cubit.toConfirm();

      expect(cubit.state.step, BorrowStep.confirm);
      expect(cubit.state.submitIdempotencyKey, isNotNull);
      expect(cubit.state.submitIdempotencyKey, isNotEmpty);
    });

    test('toConfirm emits borrowCannotBorrowNow when terms disallow borrow', () async {
      when(
        () => getTerms(projectId: any(named: 'projectId'), amount: any(named: 'amount')),
      ).thenAnswer(
        (_) async => const Right(
          BorrowTermsEntity(
            amount: 100,
            currency: 'USD',
            dueByDisplay: 'Jun 1, 2026',
            penaltyPercentage: 10,
            penaltyIfMissedDisplay: '10%',
            penaltyAppliesDisplay: 'One time',
            agreementText: 'Agree',
            canBorrow: false,
          ),
        ),
      );

      final cubit = createCubit();
      addTearDown(cubit.close);

      cubit.setAmountDigits('10000');
      await cubit.toConfirm();

      expect(cubit.state.step, BorrowStep.amount);
      expect(cubit.state.errorMessage, AppStrings.borrowCannotBorrowNow);
      expect(cubit.state.submitIdempotencyKey, isNull);
    });

    test('backToAmount clears idempotency key', () async {
      when(
        () => getTerms(projectId: any(named: 'projectId'), amount: any(named: 'amount')),
      ).thenAnswer((_) async => const Right(terms));

      final cubit = createCubit();
      addTearDown(cubit.close);

      cubit.setAmountDigits('10000');
      await cubit.toConfirm();
      cubit.backToAmount();

      expect(cubit.state.step, BorrowStep.amount);
      expect(cubit.state.submitIdempotencyKey, isNull);
    });

    test('submit uses default reason and stable idempotency key on retry', () async {
      when(
        () => getTerms(projectId: any(named: 'projectId'), amount: any(named: 'amount')),
      ).thenAnswer((_) async => const Right(terms));

      final capturedKeys = <String>[];
      when(
        () => createRequest(
          projectId: any(named: 'projectId'),
          amount: any(named: 'amount'),
          reason: any(named: 'reason'),
          idempotencyKey: any(named: 'idempotencyKey'),
        ),
      ).thenAnswer((invocation) async {
        capturedKeys.add(
          invocation.namedArguments[#idempotencyKey]! as String,
        );
        if (capturedKeys.length == 1) {
          return const Left(ServerFailure('Try again'));
        }
        return const Right(borrowResult);
      });

      final cubit = createCubit();
      addTearDown(cubit.close);

      cubit.setAmountDigits('10000');
      await cubit.toConfirm();
      cubit.setTermsAccepted(true);

      final keyBefore = cubit.state.submitIdempotencyKey;
      cubit.submit();
      await cubit.stream.firstWhere((s) => s.errorMessage != null);
      expect(cubit.state.errorMessage, isNotNull);

      cubit.submit();
      await cubit.stream.firstWhere((s) => s.step == BorrowStep.success);
      expect(cubit.state.step, BorrowStep.success);
      expect(capturedKeys, hasLength(2));
      expect(capturedKeys.first, keyBefore);
      expect(capturedKeys.first, capturedKeys.last);

      verify(
        () => createRequest(
          projectId: 'proj-1',
          amount: 100,
          reason: AppStrings.borrowDefaultReason,
          idempotencyKey: keyBefore!,
        ),
      ).called(2);
    });
  });
}
