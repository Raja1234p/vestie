import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/validation_utils.dart';

class RegisterFormState extends Equatable {
  final bool passwordVisible;
  final bool confirmVisible;
  final String? nameError;
  final String? emailError;
  final String? passwordError;
  final String? confirmError;
  final bool isValid;

  const RegisterFormState({
    this.passwordVisible = false,
    this.confirmVisible = false,
    this.nameError,
    this.emailError,
    this.passwordError,
    this.confirmError,
    this.isValid = false,
  });

  RegisterFormState copyWith({
    bool? passwordVisible,
    bool? confirmVisible,
    String? nameError,
    String? emailError,
    String? passwordError,
    String? confirmError,
    bool? isValid,
    bool clearName = false,
    bool clearEmail = false,
    bool clearPassword = false,
    bool clearConfirm = false,
  }) {
    return RegisterFormState(
      passwordVisible: passwordVisible ?? this.passwordVisible,
      confirmVisible: confirmVisible ?? this.confirmVisible,
      nameError: clearName ? null : (nameError ?? this.nameError),
      emailError: clearEmail ? null : (emailError ?? this.emailError),
      passwordError:
          clearPassword ? null : (passwordError ?? this.passwordError),
      confirmError: clearConfirm ? null : (confirmError ?? this.confirmError),
      isValid: isValid ?? this.isValid,
    );
  }

  @override
  List<Object?> get props =>
      [passwordVisible, confirmVisible, nameError, emailError, passwordError, confirmError, isValid];
}

/// Manages register form UI state only.
/// All validation logic lives in ValidationUtils.
class RegisterFormCubit extends Cubit<RegisterFormState> {
  RegisterFormCubit() : super(const RegisterFormState());

  void togglePassword() =>
      emit(state.copyWith(passwordVisible: !state.passwordVisible));

  void toggleConfirm() =>
      emit(state.copyWith(confirmVisible: !state.confirmVisible));

  void clearNameError()     => emit(state.copyWith(clearName: true));
  void clearEmailError()    => emit(state.copyWith(clearEmail: true));
  void clearPasswordError() => emit(state.copyWith(clearPassword: true));
  void clearConfirmError()  => emit(state.copyWith(clearConfirm: true));

  void onFieldsChanged(String name, String email, String password, String confirm) {
    final nameErr    = ValidationUtils.validateFullName(name);
    final emailErr   = ValidationUtils.validateEmail(email);
    final passErr    = ValidationUtils.validatePassword(password);
    final confirmErr = ValidationUtils.validateConfirmPassword(confirm, password);
    emit(state.copyWith(
      isValid: nameErr == null && emailErr == null && passErr == null && confirmErr == null,
    ));
  }

  bool validate(String name, String email, String password, String confirm) {
    final nameErr    = ValidationUtils.validateFullName(name);
    final emailErr   = ValidationUtils.validateEmail(email);
    final passErr    = ValidationUtils.validatePassword(password);
    final confirmErr = ValidationUtils.validateConfirmPassword(confirm, password);
    emit(state.copyWith(
      nameError: nameErr,
      emailError: emailErr,
      passwordError: passErr,
      confirmError: confirmErr,
      isValid: nameErr == null && emailErr == null && passErr == null && confirmErr == null,
    ));
    return nameErr == null &&
        emailErr == null &&
        passErr == null &&
        confirmErr == null;
  }
}
