import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/di/service_locator.dart';
import '../../domain/entities/risk_disclaimer.dart';
import '../../domain/usecases/accept_risk_disclaimer_use_case.dart';
import '../../domain/usecases/get_risk_disclaimer_use_case.dart';

class AgreementState extends Equatable {
  final bool isAccepted;
  final bool isLoading;
  final String? error;
  final bool isSuccess;
  final RiskDisclaimer? disclaimer;

  const AgreementState({
    this.isAccepted = false,
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
    this.disclaimer,
  });

  AgreementState copyWith({
    bool? isAccepted,
    bool? isLoading,
    String? error,
    bool? isSuccess,
    RiskDisclaimer? disclaimer,
  }) {
    return AgreementState(
      isAccepted: isAccepted ?? this.isAccepted,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isSuccess: isSuccess ?? this.isSuccess,
      disclaimer: disclaimer ?? this.disclaimer,
    );
  }

  @override
  List<Object?> get props => [isAccepted, isLoading, error, isSuccess, disclaimer];
}

class AgreementCubit extends Cubit<AgreementState> {
  final AcceptRiskDisclaimerUseCase _acceptRiskDisclaimerUseCase;
  final GetRiskDisclaimerUseCase _getRiskDisclaimerUseCase;

  AgreementCubit({
    AcceptRiskDisclaimerUseCase? acceptRiskDisclaimerUseCase,
    GetRiskDisclaimerUseCase? getRiskDisclaimerUseCase,
  })  : _acceptRiskDisclaimerUseCase = acceptRiskDisclaimerUseCase ??
            ServiceLocator.instance.acceptRiskDisclaimerUseCase,
        _getRiskDisclaimerUseCase = getRiskDisclaimerUseCase ??
            ServiceLocator.instance.getRiskDisclaimerUseCase,
        super(const AgreementState()) {
    fetchDisclaimer();
  }

  Future<void> fetchDisclaimer() async {
    emit(state.copyWith(isLoading: true, error: null));
    final result = await _getRiskDisclaimerUseCase();
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
      (disclaimer) => emit(state.copyWith(isLoading: false, disclaimer: disclaimer)),
    );
  }

  void toggle() => emit(state.copyWith(isAccepted: !state.isAccepted));

  Future<void> submit() async {
    if (!state.isAccepted || state.disclaimer == null) return;

    emit(state.copyWith(isLoading: true, error: null, isSuccess: false));

    final result = await _acceptRiskDisclaimerUseCase(
      version: state.disclaimer!.version,
      ipAddress: ApiConstants.defaultIpAddress,
    );

    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
      (_) => emit(state.copyWith(isLoading: false, isSuccess: true)),
    );
  }
}
