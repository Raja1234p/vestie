import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/validation_utils.dart';

// ─── State ──────────────────────────────────────────────────────────────────
class VerificationState extends Equatable {
  final bool isLoading;
  final String? error;
  final bool isSuccess;
  final int resendSeconds;

  const VerificationState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
    this.resendSeconds = 60,
  });

  bool get canResend => resendSeconds == 0;

  VerificationState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
    int? resendSeconds,
    bool clearError = false,
  }) {
    return VerificationState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isSuccess: isSuccess ?? this.isSuccess,
      resendSeconds: resendSeconds ?? this.resendSeconds,
    );
  }

  @override
  List<Object?> get props => [isLoading, error, isSuccess, resendSeconds];
}

// ─── Cubit ──────────────────────────────────────────────────────────────────
/// WHY Cubit (not BLoC):
/// Verification is a single linear flow. The resend timer is an internal
/// side-effect. Cubit's simpler emit() API is sufficient.
class VerificationCubit extends Cubit<VerificationState> {
  final String email;
  Timer? _timer;

  VerificationCubit({required this.email}) : super(const VerificationState()) {
    _startResendCountdown();
  }

  void _startResendCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.resendSeconds <= 0) {
        _timer?.cancel();
        return;
      }
      if (!isClosed) {
        emit(state.copyWith(resendSeconds: state.resendSeconds - 1));
      }
    });
  }

  Future<void> verifyCode(String code) async {
    final err = ValidationUtils.validateOtpCode(code);
    if (err != null) {
      emit(state.copyWith(error: err));
      return;
    }
    emit(state.copyWith(isLoading: true, clearError: true));
    await Future.delayed(const Duration(milliseconds: 1200));
    // TODO: Replace with real AuthRepository.verifyOtp(email: email, code: code)
    if (!isClosed) emit(state.copyWith(isLoading: false, isSuccess: true));
  }

  void resendCode() {
    if (!state.canResend) return;
    emit(state.copyWith(resendSeconds: 60, clearError: true));
    _startResendCountdown();
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
