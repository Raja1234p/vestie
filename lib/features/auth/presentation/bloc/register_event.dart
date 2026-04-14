import 'package:equatable/equatable.dart';

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();
}

class RegisterSubmitted extends RegisterEvent {
  final String name;
  final String email;
  final String password;

  const RegisterSubmitted({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [name, email, password];
}

class RegisterReset extends RegisterEvent {
  const RegisterReset();

  @override
  List<Object> get props => [];
}
