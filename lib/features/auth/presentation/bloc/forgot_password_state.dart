import 'package:equatable/equatable.dart';

abstract class ForgotPasswordState extends Equatable {
  const ForgotPasswordState();
}

class ForgotPasswordInitial extends ForgotPasswordState {
  const ForgotPasswordInitial();
  @override List<Object> get props => [];
}

class ForgotPasswordLoading extends ForgotPasswordState {
  const ForgotPasswordLoading();
  @override List<Object> get props => [];
}

/// Reset email sent successfully — navigate to set-new-password screen.
class ForgotPasswordSuccess extends ForgotPasswordState {
  final String email;
  final String message;
  const ForgotPasswordSuccess({required this.email, required this.message});
  @override
  List<Object> get props => [email, message];
}

class ForgotPasswordError extends ForgotPasswordState {
  final String message;
  final String? title;
  const ForgotPasswordError({required this.message, this.title});
  @override List<Object?> get props => [message, title];
}
