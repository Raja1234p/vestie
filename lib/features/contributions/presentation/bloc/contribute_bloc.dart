import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import '../../domain/usecases/preview_contribution_usecase.dart';
import '../../domain/usecases/confirm_contribution_usecase.dart';
import 'contribute_event.dart';
import 'contribute_state.dart';

EventTransformer<Event> debounce<Event>(Duration duration) {
  return (events, mapper) => events.debounceTime(duration).switchMap(mapper);
}

class ContributeBloc extends Bloc<ContributeEvent, ContributeState> {
  final PreviewContributionUseCase previewUseCase;
  final ConfirmContributionUseCase confirmUseCase;

  ContributeBloc({
    required this.previewUseCase,
    required this.confirmUseCase,
  }) : super(const ContributeState()) {
    on<InitArgsEvent>((event, emit) {
      emit(state.copyWith(args: event.args));
    });

    on<DigitsChangedEvent>((event, emit) {
      var d = event.digits.replaceAll(RegExp(r'[^0-9]'), '');
      if (d.length > 8) d = d.substring(0, 8);
      while (d.length > 1 && d.startsWith('0')) {
        d = d.substring(1);
      }
      if (d.length == 1 && d == '0') d = '';
      emit(state.copyWith(amountDigits: d));
    });

    on<SetNonRefundableEvent>((event, emit) {
      emit(state.copyWith(nonRefundableAccepted: event.accepted));
    });

    on<BackToAmountEvent>((event, emit) {
      emit(state.copyWith(step: ContributeStep.amount));
    });

    on<GoToConfirmEvent>(_onGoToConfirm);

    on<AmountChangedEvent>(
      _onAmountChanged,
      transformer: debounce(const Duration(milliseconds: 500)),
    );
    on<ConfirmSubmitEvent>(_onConfirmSubmit);
  }

  Future<void> _onGoToConfirm(GoToConfirmEvent event, Emitter<ContributeState> emit) async {
    if (state.amountValue <= 0) return;

    emit(state.copyWith(isPreviewLoading: true, clearPreviewFailure: true, clearSubmitFailure: true));

    final result = await previewUseCase(PreviewContributionParams(
      projectId: state.args?.projectId ?? '',
      amount: state.amountValue,
    ));

    result.fold(
      (failure) => emit(state.copyWith(isPreviewLoading: false, previewFailure: failure)),
      (preview) => emit(state.copyWith(
        isPreviewLoading: false,
        preview: preview,
        step: ContributeStep.confirm,
      )),
    );
  }

  Future<void> _onAmountChanged(AmountChangedEvent event, Emitter<ContributeState> emit) async {
    if (event.amount <= 0) {
      emit(state.copyWith(preview: null, clearPreviewFailure: true));
      return;
    }

    emit(state.copyWith(isPreviewLoading: true, clearPreviewFailure: true, clearSubmitFailure: true));

    final result = await previewUseCase(PreviewContributionParams(
      projectId: event.projectId,
      amount: event.amount,
    ));

    result.fold(
      (failure) => emit(state.copyWith(isPreviewLoading: false, previewFailure: failure)),
      (preview) => emit(state.copyWith(isPreviewLoading: false, preview: preview)),
    );
  }

  Future<void> _onConfirmSubmit(ConfirmSubmitEvent event, Emitter<ContributeState> emit) async {
    emit(state.copyWith(isSubmitLoading: true, clearSubmitFailure: true));

    final result = await confirmUseCase(ConfirmContributionParams(
      projectId: event.projectId,
      amount: event.amount,
      walletId: event.walletId,
    ));

    result.fold(
      (failure) {
        emit(state.copyWith(isSubmitLoading: false, submitFailure: failure));
      },
      (_) => emit(state.copyWith(
        isSubmitLoading: false,
        isSubmitSuccess: true,
        step: ContributeStep.success,
      )),
    );
  }
}
