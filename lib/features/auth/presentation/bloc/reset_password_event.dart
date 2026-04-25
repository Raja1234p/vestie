import 'package:equatable/equatable.dart';

abstract class ResetPasswordEvent extends Equatable {
  const ResetPasswordEvent();
}

class ResetPasswordSubmitted extends ResetPasswordEvent {
  final String email;
  final String code;
  final String newPassword;

  const ResetPasswordSubmitted({
    required this.email,
    required this.code,
    required this.newPassword,
  });

  @override
  List<Object> get props => [email, code, newPassword];
}

class ResetPasswordReset extends ResetPasswordEvent {
  const ResetPasswordReset();
  @override
  List<Object> get props => [];
}
