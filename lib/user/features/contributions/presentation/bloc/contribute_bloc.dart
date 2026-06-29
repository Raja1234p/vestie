import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/services/payment_methods_prefetch.dart';
import 'package:vestie/core/error/failures.dart';
import 'package:vestie/core/services/home_project_list_sync.dart';
import 'package:vestie/core/utils/contribution_fee_policy.dart';
import 'package:vestie/features/project_detail/presentation/project_detail_reload_coordinator.dart';
import 'package:vestie/features/wallet/domain/usecases/get_wallet_use_case.dart';
import 'package:vestie/features/wallet/domain/wallet_balance_cache.dart';
import '../../domain/usecases/confirm_contribution_usecase.dart';
import '../../domain/usecases/fetch_contribution_config_usecase.dart';
import '../../domain/usecases/preview_contribution_usecase.dart';
import 'contribute_event.dart';
import 'contribute_state.dart';

EventTransformer<Event> debounce<Event>(Duration duration) {
  return (events, mapper) => events.debounceTime(duration).switchMap(mapper);
}

class ContributeBloc extends Bloc<ContributeEvent, ContributeState> {
  final FetchContributionConfigUseCase configUseCase;
  final PreviewContributionUseCase previewUseCase;
  final ConfirmContributionUseCase confirmUseCase;
  final GetWalletUseCase getWalletUseCase;

  ContributeBloc({
    required this.configUseCase,
    required this.previewUseCase,
    required this.confirmUseCase,
    required this.getWalletUseCase,
  }) : super(const ContributeState()) {
    on<InitArgsEvent>(_onInitArgs);

    on<DigitsChangedEvent>((event, emit) {
      var d = event.digits.replaceAll(RegExp(r'[^0-9]'), '');
      if (d.length > 8) d = d.substring(0, 8);
      while (d.length > 1 && d.startsWith('0')) {
        d = d.substring(1);
      }
      if (d.length == 1 && d == '0') d = '';
      emit(state.copyWith(amountDigits: d, clearPreview: true));
    });

    on<SetNonRefundableEvent>((event, emit) {
      emit(state.copyWith(nonRefundableAccepted: event.accepted));
    });

    on<BackToAmountEvent>((event, emit) {
      emit(state.copyWith(step: ContributeStep.amount, clearPreview: true));
    });

    on<GoToConfirmEvent>(_onGoToConfirm);
    on<ContributePaymentMethodSelectedEvent>(_onPaymentMethodSelected);

    on<AmountChangedEvent>(
      _onAmountChanged,
      transformer: debounce(const Duration(milliseconds: 500)),
    );
    on<ConfirmSubmitEvent>(_onConfirmSubmit);
  }

  Future<void> _onInitArgs(
    InitArgsEvent event,
    Emitter<ContributeState> emit,
  ) async {
    final cachedWallet = WalletBalanceCache.value;
    var walletBalance =
        cachedWallet?.availableBalance ?? event.args.walletBalance;
    var walletId = cachedWallet?.walletId ?? '';

    emit(
      state.copyWith(
        args: event.args.copyWithWalletBalance(walletBalance),
        isConfigLoading: true,
        clearPreviewFailure: true,
        clearSubmitFailure: true,
      ),
    );

    final walletResult = await getWalletUseCase();
    walletResult.fold((_) {}, (w) {
      walletBalance = w.availableBalance;
      walletId = w.walletId;
    });

    unawaited(PaymentMethodsPrefetch.warmIfNeeded());

    final configResult = await configUseCase(projectId: event.args.projectId);
    configResult.fold(
      (_) {
        emit(
          state.copyWith(
            isConfigLoading: false,
            selectedWalletId: walletId.isNotEmpty ? walletId : 'wallet',
            args: event.args.copyWithWalletBalance(walletBalance),
          ),
        );
      },
      (config) {
        final id = config.wallets.isNotEmpty
            ? config.wallets.first.walletId
            : walletId;
        emit(
          state.copyWith(
            isConfigLoading: false,
            selectedWalletId: id.isNotEmpty ? id : 'wallet',
            args: event.args.copyWithWalletBalance(
              config.wallets.isNotEmpty
                  ? config.wallets.first.availableBalance
                  : walletBalance,
            ),
          ),
        );
      },
    );
  }

  Future<void> _onGoToConfirm(
    GoToConfirmEvent event,
    Emitter<ContributeState> emit,
  ) async {
    if (state.isPreviewLoading) return;

    final args = state.args;
    if (args == null || state.amountValue <= 0) return;

    final validation = ContributionFeePolicy.validateAmount(state.amountValue);
    if (validation != null) {
      emit(state.copyWith(previewFailure: ValidationFailure(validation)));
      return;
    }

    emit(
      state.copyWith(
        isPreviewLoading: true,
        clearPreviewFailure: true,
        clearSubmitFailure: true,
      ),
    );

    final result = await previewUseCase(
      PreviewContributionParams(
        projectId: args.projectId,
        membershipId: args.membershipId ?? '',
        walletId: state.selectedWalletId,
        amount: state.amountValue,
        currency: 'USD',
        confirmNonRefundable: state.nonRefundableAccepted,
      ),
    );

    if (isClosed) return;

    await result.fold(
      (failure) async {
        emit(state.copyWith(isPreviewLoading: false, previewFailure: failure));
      },
      (preview) async {
        final withPreview = state.copyWith(preview: preview);
        if (!withPreview.walletCoversTotal) {
          final shortfall =
              (withPreview.totalDeductionValue - withPreview.walletBalance)
                  .clamp(0.0, double.infinity);
          emit(
            state.copyWith(
              isPreviewLoading: false,
              previewFailure: ValidationFailure(
                AppStrings.contributeDepositForWalletMessage(
                  '\$${shortfall.toStringAsFixed(2)}',
                ),
              ),
            ),
          );
          return;
        }
        emit(
          state.copyWith(
            isPreviewLoading: false,
            preview: preview,
            step: ContributeStep.confirm,
            clearSelectedCard: true,
            payFromWallet: true,
            requiresPaymentMethodPicker: false,
            canChangePaymentMethod: false,
          ),
        );
      },
    );
  }

  void _onPaymentMethodSelected(
    ContributePaymentMethodSelectedEvent event,
    Emitter<ContributeState> emit,
  ) {
    emit(
      state.copyWith(
        clearSelectedCard: true,
        payFromWallet: true,
        requiresPaymentMethodPicker: false,
        canChangePaymentMethod: false,
      ),
    );
  }

  Future<void> _onAmountChanged(
    AmountChangedEvent event,
    Emitter<ContributeState> emit,
  ) async {
    if (event.amount <= 0) {
      emit(state.copyWith(clearPreview: true, clearPreviewFailure: true));
    }
  }

  Future<void> _onConfirmSubmit(
    ConfirmSubmitEvent event,
    Emitter<ContributeState> emit,
  ) async {
    final args = state.args;
    if (args == null || state.preview == null) return;

    if (state.isSubmitLoading) return;
    if (!state.canConfirmSubmit) return;

    final capValidation = ContributionFeePolicy.validateAmount(state.amountValue);
    if (capValidation != null) {
      emit(state.copyWith(submitFailure: ValidationFailure(capValidation)));
      return;
    }

    emit(state.copyWith(isSubmitLoading: true, clearSubmitFailure: true));

    final result = await confirmUseCase(
      ConfirmContributionParams(
        projectId: args.projectId,
        membershipId: args.membershipId ?? '',
        amount: state.amountValue,
        walletId: state.selectedWalletId,
        currency: state.preview!.currency,
        confirmNonRefundable: state.nonRefundableAccepted,
      ),
    );

    if (isClosed) return;

    await result.fold(
      (failure) async {
        emit(state.copyWith(isSubmitLoading: false, submitFailure: failure));
      },
      (submitResult) async {
        WalletBalanceCache.patchAvailableBalance(
          submitResult.walletAvailableBalance,
        );
        HomeProjectListSync.recordContribution(
          projectId: args.projectId,
          projectPot: submitResult.projectPot,
        );

        await ProjectDetailReloadCoordinator.reloadAfterContribution(
          projectId: args.projectId,
          projectPot: submitResult.projectPot,
          vffMemberUserIds: submitResult.vffMemberUserIds,
        );

        if (isClosed) return;

        emit(
          state.copyWith(
            isSubmitLoading: false,
            isSubmitSuccess: true,
            step: ContributeStep.success,
            submitResult: submitResult,
            args: args.copyWithWalletBalance(
              submitResult.walletAvailableBalance,
            ),
          ),
        );
      },
    );
  }
}
