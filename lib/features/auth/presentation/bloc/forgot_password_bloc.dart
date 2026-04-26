import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../domain/usecases/forgot_password_use_case.dart';
import 'forgot_password_event.dart';
import 'forgot_password_state.dart';

/// Handles forgot-password API flow.
class ForgotPasswordBloc extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  final ForgotPasswordUseCase _forgotPasswordUseCase;

  ForgotPasswordBloc({ForgotPasswordUseCase? forgotPasswordUseCase})
      : _forgotPasswordUseCase = forgotPasswordUseCase ??
            ServiceLocator.instance.forgotPasswordUseCase,
        super(const ForgotPasswordInitial()) {
    on<ForgotPasswordSubmitted>(_onForgotPasswordSubmitted);
    on<ForgotPasswordReset>((_, emit) => emit(const ForgotPasswordInitial()));
  }

  Future<void> _onForgotPasswordSubmitted(
    ForgotPasswordSubmitted event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(const ForgotPasswordLoading());

    final result = await _forgotPasswordUseCase(email: event.email);

    result.fold(
      (failure) => emit(ForgotPasswordError(message: failure.message, title: failure.title)),
      (message) => emit(ForgotPasswordSuccess(email: event.email, message: message)),
    );
  }
}
