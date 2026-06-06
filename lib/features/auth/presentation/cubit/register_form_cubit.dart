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
      passwordError: clearPassword
          ? null
          : (passwordError ?? this.passwordError),
      confirmError: clearConfirm ? null : (confirmError ?? this.confirmError),
      isValid: isValid ?? this.isValid,
    );
  }

  @override
  List<Object?> get props => [
    passwordVisible,
    confirmVisible,
    nameError,
    emailError,
    passwordError,
    confirmError,
    isValid,
  ];
}

/// Manages register form UI state only.
/// All validation logic lives in ValidationUtils.
class RegisterFormCubit extends Cubit<RegisterFormState> {
  RegisterFormCubit() : super(const RegisterFormState());

  void togglePassword() =>
      emit(state.copyWith(passwordVisible: !state.passwordVisible));

  void toggleConfirm() =>
      emit(state.copyWith(confirmVisible: !state.confirmVisible));

  void clearNameError() => emit(state.copyWith(clearName: true));
  void clearEmailError() => emit(state.copyWith(clearEmail: true));
  void clearPasswordError() => emit(state.copyWith(clearPassword: true));
  void clearConfirmError() => emit(state.copyWith(clearConfirm: true));

  void onFieldsChanged(
    String name,
    String email,
    String password,
    String confirm,
  ) {
    emit(
      state.copyWith(
        clearName:
            state.nameError != null &&
            ValidationUtils.validateFullName(name) == null,
        clearEmail:
            state.emailError != null &&
            ValidationUtils.validateEmail(email) == null,
        clearPassword:
            state.passwordError != null &&
            ValidationUtils.validatePassword(password) == null,
        clearConfirm:
            state.confirmError != null &&
            ValidationUtils.validateConfirmPassword(confirm, password) == null,
      ),
    );
  }

  /// Runs all field rules, shows errors on the form, returns whether submit may proceed.
  bool validate(String name, String email, String password, String confirm) {
    final nameErr = ValidationUtils.validateFullName(name);
    final emailErr = ValidationUtils.validateEmail(email);
    final passErr = ValidationUtils.validatePassword(password);
    final confirmErr = ValidationUtils.validateConfirmPassword(
      confirm,
      password,
    );
    final allValid =
        nameErr == null &&
        emailErr == null &&
        passErr == null &&
        confirmErr == null;

    // Full emit so null errors clear previous messages (copyWith cannot set null).
    emit(
      RegisterFormState(
        passwordVisible: state.passwordVisible,
        confirmVisible: state.confirmVisible,
        nameError: nameErr,
        emailError: emailErr,
        passwordError: passErr,
        confirmError: confirmErr,
        isValid: allValid,
      ),
    );
    return allValid;
  }

  /// Fresh register form (e.g. after route returns); pair with clearing controllers.
  void reset() => emit(const RegisterFormState());
}
