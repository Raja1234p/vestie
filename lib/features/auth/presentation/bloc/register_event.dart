import 'package:equatable/equatable.dart';

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();
}

class RegisterSubmitted extends RegisterEvent {
  final String name;
  final String email;
  final String password;
  final String confirmPassword;

  const RegisterSubmitted({
    required this.name,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  @override
  List<Object> get props => [name, email, password, confirmPassword];
}

class RegisterReset extends RegisterEvent {
  const RegisterReset();

  @override
  List<Object> get props => [];
}

class GoogleRegisterRequested extends RegisterEvent {
  const GoogleRegisterRequested();

  @override
  List<Object> get props => [];
}
