import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../domain/usecases/reset_password_use_case.dart';
import 'reset_password_event.dart';
import 'reset_password_state.dart';

/// Handles set-new-password API flow.
class ResetPasswordBloc extends Bloc<ResetPasswordEvent, ResetPasswordState> {
  final ResetPasswordUseCase _resetPasswordUseCase;

  ResetPasswordBloc({ResetPasswordUseCase? resetPasswordUseCase})
      : _resetPasswordUseCase = resetPasswordUseCase ??
            ServiceLocator.instance.resetPasswordUseCase,
        super(const ResetPasswordInitial()) {
    on<ResetPasswordSubmitted>(_onResetPasswordSubmitted);
    on<ResetPasswordReset>((_, emit) => emit(const ResetPasswordInitial()));
  }

  Future<void> _onResetPasswordSubmitted(
    ResetPasswordSubmitted event,
    Emitter<ResetPasswordState> emit,
  ) async {
    emit(const ResetPasswordLoading());

    final result = await _resetPasswordUseCase(
      email: event.email,
      code: event.code,
      newPassword: event.newPassword,
      confirmNewPassword: event.newPassword, // API requires confirmation too
    );

    result.fold(
      (failure) => emit(ResetPasswordError(message: failure.message, title: failure.title)),
      (_) => emit(const ResetPasswordSuccess()),
    );
  }
}
