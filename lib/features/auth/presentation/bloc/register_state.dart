import 'package:equatable/equatable.dart';

abstract class RegisterState extends Equatable {
  const RegisterState();
}

class RegisterInitial extends RegisterState {
  const RegisterInitial();
  @override
  List<Object> get props => [];
}

class RegisterLoading extends RegisterState {
  const RegisterLoading();
  @override
  List<Object> get props => [];
}

/// Registration succeeded — carry email to OTP verify screen.
class RegisterSuccess extends RegisterState {
  final String email;
  const RegisterSuccess({required this.email});
  @override
  List<Object> get props => [email];
}

class RegisterGoogleSuccess extends RegisterState {
  final bool isDisclaimerAccepted;
  const RegisterGoogleSuccess({this.isDisclaimerAccepted = false});
  @override
  List<Object> get props => [isDisclaimerAccepted];
}

class RegisterError extends RegisterState {
  final String message;
  final String? title;
  const RegisterError({required this.message, this.title});
  @override
  List<Object?> get props => [message, title];
}
