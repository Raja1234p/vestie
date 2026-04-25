import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/validation_utils.dart';

class ForgotPasswordFormState extends Equatable {
  final String? emailError;
  final bool isValid;

  const ForgotPasswordFormState({this.emailError, this.isValid = false});

  ForgotPasswordFormState copyWith({
    String? emailError,
    bool? isValid,
    bool clearError = false,
  }) {
    return ForgotPasswordFormState(
      emailError: clearError ? null : (emailError ?? this.emailError),
      isValid: isValid ?? this.isValid,
    );
  }

  @override
  List<Object?> get props => [emailError, isValid];
}

/// Manages forgot-password form UI state — no setState.
class ForgotPasswordFormCubit extends Cubit<ForgotPasswordFormState> {
  ForgotPasswordFormCubit() : super(const ForgotPasswordFormState());

  void clearError() => emit(state.copyWith(clearError: true));

  void onFieldsChanged(String email) {
    emit(state.copyWith(isValid: ValidationUtils.validateEmail(email) == null));
  }

  bool validate(String email) {
    final err = ValidationUtils.validateEmail(email);
    emit(state.copyWith(emailError: err, isValid: err == null));
    return err == null;
  }
}
