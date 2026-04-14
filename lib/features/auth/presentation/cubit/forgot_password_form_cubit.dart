import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/validation_utils.dart';

class ForgotPasswordFormState extends Equatable {
  final String? emailError;
  const ForgotPasswordFormState({this.emailError});

  ForgotPasswordFormState copyWith({String? emailError, bool clearError = false}) {
    return ForgotPasswordFormState(
      emailError: clearError ? null : (emailError ?? this.emailError),
    );
  }

  @override
  List<Object?> get props => [emailError];
}

/// Manages forgot-password form UI state — no setState.
class ForgotPasswordFormCubit extends Cubit<ForgotPasswordFormState> {
  ForgotPasswordFormCubit() : super(const ForgotPasswordFormState());

  void clearError() => emit(state.copyWith(clearError: true));

  bool validate(String email) {
    final err = ValidationUtils.validateEmail(email);
    emit(state.copyWith(emailError: err));
    return err == null;
  }
}
