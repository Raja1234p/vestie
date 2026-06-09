import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vestie/core/error/failures.dart';
import 'package:vestie/user/features/borrow/domain/entities/borrow_repay_entities.dart';
import 'package:vestie/user/features/borrow/domain/usecases/submit_borrow_repayment_use_case.dart';
import 'package:vestie/user/features/borrow/presentation/cubit/borrow_repay_confirm_cubit.dart';

class _MockSubmitBorrowRepaymentUseCase extends Mock
    implements SubmitBorrowRepaymentUseCase {}

void main() {
  late _MockSubmitBorrowRepaymentUseCase submitUseCase;

  const success = BorrowRepaymentResultEntity(
    repaymentId: 'pay-1',
    totalRepaid: 345,
    projectName: 'Europe 2025',
    message: 'Repaid',
  );

  setUp(() {
    submitUseCase = _MockSubmitBorrowRepaymentUseCase();
  });

  BorrowRepayConfirmCubit createCubit() => BorrowRepayConfirmCubit(
    projectId: 'proj-1',
    borrowRequestId: 'req-1',
    paymentSourceType: 'Wallet',
    submitUseCase: submitUseCase,
  );

  group('BorrowRepayConfirmCubit', () {
    test('submit retries with the same idempotency key', () async {
      final capturedKeys = <String>[];
      when(
        () => submitUseCase(
          projectId: any(named: 'projectId'),
          borrowRequestId: any(named: 'borrowRequestId'),
          paymentSourceType: any(named: 'paymentSourceType'),
          paymentMethodId: any(named: 'paymentMethodId'),
          idempotencyKey: any(named: 'idempotencyKey'),
        ),
      ).thenAnswer((invocation) async {
        capturedKeys.add(
          invocation.namedArguments[#idempotencyKey]! as String,
        );
        if (capturedKeys.length == 1) {
          return const Left(ServerFailure('Try again'));
        }
        return const Right(success);
      });

      final cubit = createCubit();
      addTearDown(cubit.close);

      expect(await cubit.submit(), isNull);
      expect(cubit.state.errorMessage, isNotNull);

      expect(await cubit.submit(), success);
      expect(capturedKeys, hasLength(2));
      expect(capturedKeys.first, capturedKeys.last);
      expect(capturedKeys.first, isNotEmpty);
    });
  });
}
