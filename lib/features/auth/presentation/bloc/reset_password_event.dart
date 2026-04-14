import 'package:equatable/equatable.dart';

abstract class ResetPasswordEvent extends Equatable {
  const ResetPasswordEvent();
}

class ResetPasswordSubmitted extends ResetPasswordEvent {
  final String newPassword;
  const ResetPasswordSubmitted({required this.newPassword});
  @override
  List<Object> get props => [newPassword];
}

class ResetPasswordReset extends ResetPasswordEvent {
  const ResetPasswordReset();
  @override
  List<Object> get props => [];
}
