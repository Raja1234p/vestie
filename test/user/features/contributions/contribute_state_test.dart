import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/app/router/route_args/project_wallet_flow_args.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/user/features/contributions/domain/entities/contribution_preview_entity.dart';
import 'package:vestie/user/features/contributions/presentation/bloc/contribute_state.dart';

void main() {
  const preview = ContributionPreviewEntity(
    amount: 1000,
    platformFee: 30,
    totalDeduction: 1030,
    currency: 'USD',
  );

  const args = ProjectWalletFlowArgs(
    projectId: 'p1',
    projectName: 'Trip',
    walletBalance: 11,
    goalAmount: 5000,
    currentAmount: 4800,
  );

  group('ContributeState amount step', () {
    test('canProceedFromAmount false when amount is zero', () {
      const state = ContributeState(args: args, amountDigits: '');

      expect(state.canProceedFromAmount, isFalse);
    });

    test('canProceedFromAmount false when wallet cannot cover total', () {
      const state = ContributeState(
        args: args,
        amountDigits: '100000',
      );

      expect(state.canProceedFromAmount, isFalse);
      expect(state.amountStepValidationMessage, isNotNull);
    });

    test('canProceedFromAmount true when wallet covers contribution and fee', () {
      const richArgs = ProjectWalletFlowArgs(
        projectId: 'p1',
        projectName: 'Trip',
        walletBalance: 2000,
      );
      const state = ContributeState(
        args: richArgs,
        amountDigits: '100000',
      );

      expect(state.canProceedFromAmount, isTrue);
      expect(state.amountStepValidationMessage, isNull);
    });
  });

  group('ContributeState confirm gating', () {
    test('canTapConfirm false until non-refundable switch accepted', () {
      const richArgs = ProjectWalletFlowArgs(
        projectId: 'p1',
        projectName: 'Trip',
        walletBalance: 2000,
      );
      const state = ContributeState(
        args: richArgs,
        preview: preview,
        payFromWallet: true,
        nonRefundableAccepted: false,
      );

      expect(state.canConfirmSubmit, isFalse);
      expect(state.canTapConfirm, isFalse);
    });

    test('canTapConfirm false when wallet cannot cover total', () {
      const state = ContributeState(
        args: args,
        preview: preview,
        payFromWallet: true,
        nonRefundableAccepted: true,
      );

      expect(state.walletCoversTotal, isFalse);
      expect(state.canConfirmSubmit, isFalse);
      expect(state.canTapConfirm, isFalse);
      expect(state.paymentValidationMessage, isNotNull);
      expect(state.hasPaymentValidationError, isTrue);
    });

    test('canTapConfirm true when switch on and wallet covers total', () {
      const richArgs = ProjectWalletFlowArgs(
        projectId: 'p1',
        projectName: 'Trip',
        walletBalance: 2000,
      );
      const state = ContributeState(
        args: richArgs,
        preview: preview,
        payFromWallet: true,
        nonRefundableAccepted: true,
      );

      expect(state.canTapConfirm, isTrue);
      expect(state.hasPaymentValidationError, isFalse);
    });

    test('card picker is disabled for wallet-only contributions', () {
      const state = ContributeState(
        args: args,
        preview: preview,
        amountDigits: '100000',
      );

      expect(state.canPickPaymentMethodOnAmount, isFalse);
      expect(state.canPickPaymentMethodOnConfirm, isFalse);
    });
  });
}
