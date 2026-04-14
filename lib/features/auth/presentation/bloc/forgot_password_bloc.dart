import 'package:flutter_bloc/flutter_bloc.dart';
import 'forgot_password_event.dart';
import 'forgot_password_state.dart';

/// Handles forgot-password email dispatch.
/// TODO: Inject AuthRepository when data layer is ready.
class ForgotPasswordBloc
    extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  ForgotPasswordBloc() : super(const ForgotPasswordInitial()) {
    on<ForgotPasswordSubmitted>(_onSubmitted);
    on<ForgotPasswordReset>((_, emit) => emit(const ForgotPasswordInitial()));
  }

  Future<void> _onSubmitted(
    ForgotPasswordSubmitted event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(const ForgotPasswordLoading());
    await Future.delayed(const Duration(milliseconds: 1200));
    // TODO: Replace with AuthRepository.sendPasswordResetEmail(email)
    emit(const ForgotPasswordSuccess());
  }
}
