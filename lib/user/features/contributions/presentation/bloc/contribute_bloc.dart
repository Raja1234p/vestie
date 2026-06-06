import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/error/failures.dart';
import 'package:vestie/core/utils/contribution_fee_policy.dart';
import 'package:vestie/features/payment_methods/domain/usecases/payment_methods_usecases.dart';
import 'package:vestie/features/profile/domain/entities/payment_card.dart';
import 'package:vestie/wallet/domain/usecases/get_wallet_use_case.dart';
import 'package:vestie/wallet/domain/wallet_balance_cache.dart';
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
  final ListPaymentMethodsUseCase listPaymentMethodsUseCase;

  List<PaymentCard> _savedCards = const [];

  ContributeBloc({
    required this.configUseCase,
    required this.previewUseCase,
    required this.confirmUseCase,
    required this.getWalletUseCase,
    required this.listPaymentMethodsUseCase,
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

    final cardsResult = await listPaymentMethodsUseCase();
    cardsResult.fold(
      (_) => _savedCards = const [],
      (cards) => _savedCards = cards,
    );

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
        final next = _paymentMethodForTotal(state.copyWith(preview: preview));
        emit(
          state.copyWith(
            isPreviewLoading: false,
            preview: preview,
            step: ContributeStep.confirm,
            selectedCard: next.$1,
            payFromWallet: next.$2,
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
        selectedCard: event.card,
        payFromWallet: event.payFromWallet,
        clearSelectedCard: event.payFromWallet,
      ),
    );
  }

  (PaymentCard?, bool) _paymentMethodForTotal(ContributeState s) {
    if (s.walletCoversTotal) {
      return (null, true);
    }
    if (!s.payFromWallet && s.selectedCard != null) {
      return (s.selectedCard, false);
    }
    final card = _defaultCard();
    return (card, false);
  }

  PaymentCard? _defaultCard() {
    if (_savedCards.isEmpty) return null;
    for (final c in _savedCards) {
      if (c.isPrimary) return c;
    }
    return _savedCards.first;
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

    if (!state.canConfirmSubmit) return;

    if (!state.payFromWallet) {
      final shortfall = (state.totalDeductionValue - state.walletBalance).clamp(
        0.0,
        double.infinity,
      );
      final shortfallFormatted = '\$${shortfall.toStringAsFixed(2)}';
      emit(
        state.copyWith(
          submitFailure: ValidationFailure(
            AppStrings.contributeDepositForWalletMessage(shortfallFormatted),
          ),
        ),
      );
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

    result.fold(
      (failure) =>
          emit(state.copyWith(isSubmitLoading: false, submitFailure: failure)),
      (submitResult) {
        WalletBalanceCache.patchAvailableBalance(
          submitResult.walletAvailableBalance,
        );
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
