import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vestie/core/error/failures.dart';
import 'package:vestie/features/stripe/domain/entities/stripe_processing_fee_entity.dart';
import 'package:vestie/features/stripe/domain/usecases/get_stripe_processing_fee_use_case.dart';
import 'package:vestie/features/wallet/domain/repositories/wallet_deposit_repository.dart';
import 'package:vestie/features/wallet/domain/usecases/run_wallet_deposit_use_case.dart';
import 'package:vestie/features/wallet/presentation/cubit/wallet_deposit_cubit.dart';

class _MockGetFee extends Mock implements GetStripeProcessingFeeUseCase {}

class _MockRunDeposit extends Mock implements RunWalletDepositUseCase {}

StripeProcessingFeeEntity _fee({
  required double deposit,
  required int cents,
  bool estimated = true,
  String? paymentIntentId,
}) {
  final stripeFee = cents / 100.0;
  final net = double.parse((deposit - stripeFee).toStringAsFixed(2));
  return StripeProcessingFeeEntity(
    stripeFeeCents: cents,
    stripeFee: stripeFee,
    isEstimated: estimated,
    depositAmount: deposit,
    netAmount: net,
    paymentIntentId: paymentIntentId,
    status: estimated ? null : 'succeeded',
  );
}

void main() {
  late _MockGetFee getFee;
  late _MockRunDeposit runDeposit;

  setUp(() {
    getFee = _MockGetFee();
    runDeposit = _MockRunDeposit();
  });

  WalletDepositCubit cubit() => WalletDepositCubit(
        runWalletDepositUseCase: runDeposit,
        getStripeProcessingFeeUseCase: getFee,
      );

  test('loadProcessingFee maps API estimate for \$100', () async {
    when(() => getFee(amount: 100)).thenAnswer(
      (_) async => Right(_fee(deposit: 100, cents: 320)),
    );

    final c = cubit();
    addTearDown(c.close);

    await c.loadProcessingFee(amount: 100);

    expect(c.state.isFeeLoading, isFalse);
    expect(c.state.canSubmit, isTrue);
    expect(c.state.processingFee!.stripeFee, 3.20);
    expect(c.state.processingFee!.netAmount, 96.80);
    expect(c.state.processingFee!.isEstimated, isTrue);
  });

  test('different amounts return different fee and net credit', () async {
    when(() => getFee(amount: 50)).thenAnswer(
      (_) async => Right(_fee(deposit: 50, cents: 175)),
    );
    when(() => getFee(amount: 250)).thenAnswer(
      (_) async => Right(_fee(deposit: 250, cents: 755)),
    );

    final c = cubit();
    addTearDown(c.close);

    await c.loadProcessingFee(amount: 50);
    expect(c.state.processingFee!.stripeFee, 1.75);
    expect(c.state.processingFee!.netAmount, 48.25);

    await c.loadProcessingFee(amount: 250);
    expect(c.state.processingFee!.stripeFee, 7.55);
    expect(c.state.processingFee!.netAmount, 242.45);
  });

  test('submit replaces estimate with actual Stripe fee from paymentIntentId',
      () async {
    when(() => getFee(amount: 100)).thenAnswer(
      (_) async => Right(_fee(deposit: 100, cents: 320)),
    );
    when(() => runDeposit(amount: 100, paymentMethodId: 'pm_1')).thenAnswer(
      (_) async => const Right(
        DepositFlowOutcome(
          result: DepositFlowResult.completed,
          paymentIntentId: 'pi_abc123',
        ),
      ),
    );
    when(() => getFee(paymentIntentId: 'pi_abc123')).thenAnswer(
      (_) async => Right(
        _fee(
          deposit: 100,
          cents: 321,
          estimated: false,
          paymentIntentId: 'pi_abc123',
        ),
      ),
    );

    final c = cubit();
    addTearDown(c.close);

    await c.loadProcessingFee(amount: 100);
    expect(c.state.processingFee!.netAmount, 96.80);

    await c.submitDeposit(amount: 100, paymentMethodId: 'pm_1');

    expect(c.state.isSuccess, isTrue);
    expect(c.state.processingFee!.isEstimated, isFalse);
    expect(c.state.processingFee!.stripeFee, 3.21);
    expect(c.state.processingFee!.netAmount, 96.79);
  });

  test('submit keeps estimate when actual fee GET fails after successful pay',
      () async {
    when(() => getFee(amount: 100)).thenAnswer(
      (_) async => Right(_fee(deposit: 100, cents: 320)),
    );
    when(() => runDeposit(amount: 100, paymentMethodId: 'pm_1')).thenAnswer(
      (_) async => const Right(
        DepositFlowOutcome(
          result: DepositFlowResult.completed,
          paymentIntentId: 'pi_abc123',
        ),
      ),
    );
    when(() => getFee(paymentIntentId: 'pi_abc123')).thenAnswer(
      (_) async => const Left(ServerFailure('fee unavailable')),
    );

    final c = cubit();
    addTearDown(c.close);

    await c.loadProcessingFee(amount: 100);
    await c.submitDeposit(amount: 100, paymentMethodId: 'pm_1');

    expect(c.state.isSuccess, isTrue);
    expect(c.state.processingFee!.isEstimated, isTrue);
    expect(c.state.processingFee!.netAmount, 96.80);
  });
}
