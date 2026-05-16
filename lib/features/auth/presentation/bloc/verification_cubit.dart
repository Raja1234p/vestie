import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/constants/storage_keys.dart';
import '../../../../core/storage/onboarding_prefs.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/validation_utils.dart';
import '../../domain/usecases/forgot_password_use_case.dart';
import '../../domain/usecases/resend_code_use_case.dart';
import '../../domain/usecases/verify_email_use_case.dart';
import '../models/auth_route_extras.dart';

// ─── State ──────────────────────────────────────────────────────────────────
class VerificationState extends Equatable {
  final bool isLoading;
  final bool isResending;
  final String? error;
  final String? title;
  final bool isSuccess;
  final int resendSeconds;
  final bool isValid;
  final String? resendMessage;

  const VerificationState({
    this.isLoading = false,
    this.isResending = false,
    this.error,
    this.title,
    this.isSuccess = false,
    this.resendSeconds = 60,
    this.isValid = false,
    this.resendMessage,
  });

  bool get canResend => resendSeconds == 0;

  VerificationState copyWith({
    bool? isLoading,
    bool? isResending,
    String? error,
    String? title,
    bool? isSuccess,
    int? resendSeconds,
    bool? isValid,
    String? resendMessage,
    bool clearError = false,
    bool clearResendMessage = false,
  }) {
    return VerificationState(
      isLoading: isLoading ?? this.isLoading,
      isResending: isResending ?? this.isResending,
      error: clearError ? null : (error ?? this.error),
      title: clearError ? null : (title ?? this.title),
      isSuccess: isSuccess ?? this.isSuccess,
      resendSeconds: resendSeconds ?? this.resendSeconds,
      isValid: isValid ?? this.isValid,
      resendMessage:
          clearResendMessage ? null : (resendMessage ?? this.resendMessage),
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isResending,
        error,
        title,
        isSuccess,
        resendSeconds,
        isValid,
        resendMessage,
      ];
}

// ─── Cubit ──────────────────────────────────────────────────────────────────
class VerificationCubit extends Cubit<VerificationState> {
  VerificationCubit({
    required this.email,
    this.flow = VerifyFlow.registration,
    VerifyEmailUseCase? verifyEmailUseCase,
    ResendCodeUseCase? resendCodeUseCase,
    ForgotPasswordUseCase? forgotPasswordUseCase,
  })  : _verifyEmailUseCase =
            verifyEmailUseCase ?? ServiceLocator.instance.verifyEmailUseCase,
        _resendCodeUseCase =
            resendCodeUseCase ?? ServiceLocator.instance.resendCodeUseCase,
        _forgotPasswordUseCase =
            forgotPasswordUseCase ?? ServiceLocator.instance.forgotPasswordUseCase,
        super(const VerificationState()) {
    _startResendCountdown();
  }

  final String email;
  final VerifyFlow flow;

  final VerifyEmailUseCase _verifyEmailUseCase;
  final ResendCodeUseCase _resendCodeUseCase;
  final ForgotPasswordUseCase _forgotPasswordUseCase;
  Timer? _timer;

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

  void onCodeChanged(String code) {
    emit(state.copyWith(
        isValid: ValidationUtils.validateOtpCode(code) == null));
  }

  Future<void> verifyCode(String code) async {
    final err = ValidationUtils.validateOtpCode(code);
    if (err != null) {
      emit(state.copyWith(error: err, isValid: false));
      return;
    }

    if (flow == VerifyFlow.forgotPassword) {
      emit(state.copyWith(isLoading: true, clearError: true, isValid: true));
      if (!isClosed) {
        emit(state.copyWith(isLoading: false, isSuccess: true));
      }
      return;
    }

    emit(state.copyWith(isLoading: true, clearError: true, isValid: true));

    final result = await _verifyEmailUseCase(email: email, code: code);

    if (!isClosed) {
      result.fold(
        (failure) => emit(state.copyWith(
          isLoading: false,
          error: failure.message,
          title: failure.title,
        )),
        (user) async {
          if (user.accessToken != null) {
            await ServiceLocator.instance.secureStorage.saveString(
              StorageKeys.accessToken,
              user.accessToken!,
            );
          }
          if (user.refreshToken != null && user.refreshToken!.isNotEmpty) {
            await ServiceLocator.instance.secureStorage.saveString(
              StorageKeys.refreshToken,
              user.refreshToken!,
            );
          }
          await ServiceLocator.instance.sharedPrefs.saveBool(
            StorageKeys.isLoggedIn,
            true,
          );
          await ServiceLocator.instance.sharedPrefs.saveString(
            StorageKeys.userName,
            user.name,
          );
          await ServiceLocator.instance.sharedPrefs.saveString(
            StorageKeys.userEmail,
            user.email,
          );
          await OnboardingPrefs.markCompleted();

          if (!isClosed) {
            emit(state.copyWith(isLoading: false, isSuccess: true));
          }
        },
      );
    }
  }

  Future<void> resendCode() async {
    if (!state.canResend || state.isResending) return;
    emit(state.copyWith(
      resendSeconds: 60,
      clearError: true,
      isResending: true,
    ));
    _startResendCountdown();

    final Either<Failure, String> result = flow == VerifyFlow.forgotPassword
        ? await _forgotPasswordUseCase(email: email)
        : await _resendCodeUseCase(email: email);

    if (isClosed) return;

    result.fold(
      (failure) => emit(state.copyWith(
        isResending: false,
        error: failure.message,
        title: failure.title,
      )),
      (message) => emit(state.copyWith(
        isResending: false,
        resendMessage: message,
      )),
    );
  }

  void clearResendMessage() => emit(state.copyWith(clearResendMessage: true));

  void clearError() => emit(state.copyWith(clearError: true));

  /// After [AppRoutes.resetPassword] is popped/replaced — clear OTP UI so user can re-enter code.
  void clearCodeAfterResetPasswordRoutePopped() {
    emit(state.copyWith(
      isSuccess: false,
      isValid: false,
      isResending: false,
      clearError: true,
    ));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
