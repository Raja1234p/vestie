import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();
}

class LoginSubmitted extends LoginEvent {
  final String email;
  final String password;

  const LoginSubmitted({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class LoginReset extends LoginEvent {
  const LoginReset();

  @override
  List<Object> get props => [];
}

class GoogleLoginRequested extends LoginEvent {
  const GoogleLoginRequested();

  @override
  List<Object> get props => [];
}
