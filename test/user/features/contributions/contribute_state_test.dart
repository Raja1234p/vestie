import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/app/router/route_args/project_wallet_flow_args.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/features/profile/domain/entities/payment_card.dart';
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

  const card = PaymentCard(
    id: 'card-1',
    holderName: 'Test User',
    last4: '4242',
    maskedNumber: '•••• 4242',
    expiry: '12/30',
    brand: CardBrand.visa,
  );

  group('ContributeState project goal cap', () {
    test('canProceedFromAmount false when amount exceeds remaining goal', () {
      const state = ContributeState(
        args: args,
        amountDigits: '100000',
      );

      expect(state.remainingToGoal, 200);
      expect(state.amountExceedsProjectRemaining, isTrue);
      expect(state.canProceedFromAmount, isFalse);
    });

    test('canProceedFromAmount true within remaining goal', () {
      const state = ContributeState(
        args: args,
        amountDigits: '15000',
      );

      expect(state.canProceedFromAmount, isTrue);
    });

    test('isProjectGoalReached when pot meets goal', () {
      const fullArgs = ProjectWalletFlowArgs(
        projectId: 'p1',
        projectName: 'Trip',
        goalAmount: 5000,
        currentAmount: 5000,
      );
      const state = ContributeState(args: fullArgs, amountDigits: '1000');

      expect(state.isProjectGoalReached, isTrue);
      expect(state.canProceedFromAmount, isFalse);
    });
  });

  group('ContributeState confirm gating', () {
    test('canTapConfirm false until non-refundable switch accepted', () {
      const state = ContributeState(
        args: args,
        preview: preview,
        payFromWallet: false,
        selectedCard: card,
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
        requiresPaymentMethodPicker: true,
      );

      expect(state.walletCoversTotal, isFalse);
      expect(state.canConfirmSubmit, isFalse);
      expect(state.canTapConfirm, isFalse);
      expect(state.paymentValidationMessage,
          AppStrings.contributeWalletInsufficientSubtitle);
      expect(state.hasPaymentValidationError, isTrue);
    });

    test('canTapConfirm false until card selected when wallet insufficient', () {
      const state = ContributeState(
        args: args,
        preview: preview,
        payFromWallet: false,
        nonRefundableAccepted: true,
        requiresPaymentMethodPicker: true,
      );

      expect(state.canTapConfirm, isFalse);
      expect(state.paymentValidationMessage,
          AppStrings.contributeSelectCardRequired);
    });

    test('canTapConfirm true when switch on and card covers shortfall', () {
      const state = ContributeState(
        args: args,
        preview: preview,
        payFromWallet: false,
        selectedCard: card,
        nonRefundableAccepted: true,
      );

      expect(state.canTapConfirm, isTrue);
      expect(state.hasPaymentValidationError, isFalse);
    });

    test('canTapConfirm true when wallet covers total', () {
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
    });
  });
}
