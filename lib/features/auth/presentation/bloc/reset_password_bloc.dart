import 'package:flutter_bloc/flutter_bloc.dart';
import 'reset_password_event.dart';
import 'reset_password_state.dart';

/// Handles password reset API flow.
/// TODO: Inject AuthRepository when data layer is ready.
class ResetPasswordBloc extends Bloc<ResetPasswordEvent, ResetPasswordState> {
  ResetPasswordBloc() : super(const ResetPasswordInitial()) {
    on<ResetPasswordSubmitted>(_onSubmitted);
    on<ResetPasswordReset>((_, emit) => emit(const ResetPasswordInitial()));
  }

  Future<void> _onSubmitted(
    ResetPasswordSubmitted event,
    Emitter<ResetPasswordState> emit,
  ) async {
    emit(const ResetPasswordLoading());
    await Future.delayed(const Duration(milliseconds: 1200));
    // TODO: Replace with AuthRepository.resetPassword(newPassword)
    emit(const ResetPasswordSuccess());
  }
}
