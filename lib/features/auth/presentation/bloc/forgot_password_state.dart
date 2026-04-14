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
  const ForgotPasswordSuccess();
  @override List<Object> get props => [];
}

class ForgotPasswordError extends ForgotPasswordState {
  final String message;
  const ForgotPasswordError({required this.message});
  @override List<Object> get props => [message];
}
