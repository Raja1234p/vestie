import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/validation_utils.dart';

class LoginFormState extends Equatable {
  final bool passwordVisible;
  final String? emailError;
  final String? passwordError;

  const LoginFormState({
    this.passwordVisible = false,
    this.emailError,
    this.passwordError,
  });

  LoginFormState copyWith({
    bool? passwordVisible,
    String? emailError,
    String? passwordError,
    bool clearEmailError = false,
    bool clearPasswordError = false,
  }) {
    return LoginFormState(
      passwordVisible: passwordVisible ?? this.passwordVisible,
      emailError: clearEmailError ? null : (emailError ?? this.emailError),
      passwordError: clearPasswordError
          ? null
          : (passwordError ?? this.passwordError),
    );
  }

  @override
  List<Object?> get props => [passwordVisible, emailError, passwordError];
}

/// Manages login form UI state only.
/// Validation logic lives in ValidationUtils — cubit only calls it.
class LoginFormCubit extends Cubit<LoginFormState> {
  LoginFormCubit() : super(const LoginFormState());

  void togglePassword() =>
      emit(state.copyWith(passwordVisible: !state.passwordVisible));

  void clearEmailError() => emit(state.copyWith(clearEmailError: true));

  void clearPasswordError() => emit(state.copyWith(clearPasswordError: true));

  /// Returns true if all fields pass validation.
  bool validate(String email, String password) {
    final emailErr = ValidationUtils.validateEmail(email);
    final passErr  = ValidationUtils.validatePassword(password);
    emit(state.copyWith(emailError: emailErr, passwordError: passErr));
    return emailErr == null && passErr == null;
  }
}
