import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/validation_utils.dart';

class ResetPasswordFormState extends Equatable {
  final bool newPassVisible;
  final bool confirmVisible;
  final String? newPassError;
  final String? confirmError;

  const ResetPasswordFormState({
    this.newPassVisible = false,
    this.confirmVisible = false,
    this.newPassError,
    this.confirmError,
  });

  ResetPasswordFormState copyWith({
    bool? newPassVisible,
    bool? confirmVisible,
    String? newPassError,
    String? confirmError,
    bool clearNew = false,
    bool clearConfirm = false,
  }) {
    return ResetPasswordFormState(
      newPassVisible: newPassVisible ?? this.newPassVisible,
      confirmVisible: confirmVisible ?? this.confirmVisible,
      newPassError: clearNew ? null : (newPassError ?? this.newPassError),
      confirmError: clearConfirm ? null : (confirmError ?? this.confirmError),
    );
  }

  @override
  List<Object?> get props => [newPassVisible, confirmVisible, newPassError, confirmError];
}

class ResetPasswordFormCubit extends Cubit<ResetPasswordFormState> {
  ResetPasswordFormCubit() : super(const ResetPasswordFormState());

  void toggleNewPass()  => emit(state.copyWith(newPassVisible: !state.newPassVisible));
  void toggleConfirm()  => emit(state.copyWith(confirmVisible: !state.confirmVisible));
  void clearNewError()  => emit(state.copyWith(clearNew: true));
  void clearConfirmError() => emit(state.copyWith(clearConfirm: true));

  bool validate(String password, String confirm) {
    final passErr    = ValidationUtils.validatePassword(password);
    final confirmErr = ValidationUtils.validateConfirmPassword(confirm, password);
    emit(state.copyWith(newPassError: passErr, confirmError: confirmErr));
    return passErr == null && confirmErr == null;
  }
}
