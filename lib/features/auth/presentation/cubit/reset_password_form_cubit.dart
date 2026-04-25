import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/validation_utils.dart';

class ResetPasswordFormState extends Equatable {
  final bool newPassVisible;
  final bool confirmVisible;
  final String? newPassError;
  final String? confirmError;
  final bool isValid;

  const ResetPasswordFormState({
    this.newPassVisible = false,
    this.confirmVisible = false,
    this.newPassError,
    this.confirmError,
    this.isValid = false,
  });

  ResetPasswordFormState copyWith({
    bool? newPassVisible,
    bool? confirmVisible,
    String? newPassError,
    String? confirmError,
    bool? isValid,
    bool clearNew = false,
    bool clearConfirm = false,
  }) {
    return ResetPasswordFormState(
      newPassVisible: newPassVisible ?? this.newPassVisible,
      confirmVisible: confirmVisible ?? this.confirmVisible,
      newPassError: clearNew ? null : (newPassError ?? this.newPassError),
      confirmError: clearConfirm ? null : (confirmError ?? this.confirmError),
      isValid: isValid ?? this.isValid,
    );
  }

  @override
  List<Object?> get props => [newPassVisible, confirmVisible, newPassError, confirmError, isValid];
}

class ResetPasswordFormCubit extends Cubit<ResetPasswordFormState> {
  ResetPasswordFormCubit() : super(const ResetPasswordFormState());

  void toggleNewPass()  => emit(state.copyWith(newPassVisible: !state.newPassVisible));
  void toggleConfirm()  => emit(state.copyWith(confirmVisible: !state.confirmVisible));
  void clearNewError()  => emit(state.copyWith(clearNew: true));
  void clearConfirmError() => emit(state.copyWith(clearConfirm: true));

  void onFieldsChanged(String password, String confirm) {
    final passErr    = ValidationUtils.validatePassword(password);
    final confirmErr = ValidationUtils.validateConfirmPassword(confirm, password);
    emit(state.copyWith(isValid: passErr == null && confirmErr == null));
  }

  bool validate(String password, String confirm) {
    final passErr    = ValidationUtils.validatePassword(password);
    final confirmErr = ValidationUtils.validateConfirmPassword(confirm, password);
    emit(state.copyWith(newPassError: passErr, confirmError: confirmErr, isValid: passErr == null && confirmErr == null));
    return passErr == null && confirmErr == null;
  }
}
