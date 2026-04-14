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

class RegisterError extends RegisterState {
  final String message;
  const RegisterError({required this.message});
  @override
  List<Object> get props => [message];
}
