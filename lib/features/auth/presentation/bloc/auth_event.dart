import 'package:equatable/equatable.dart';

// ─── Auth Events (BLoC: multiple distinct event types) ─────────────────────
abstract class AuthEvent extends Equatable {
  const AuthEvent();
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  const LoginRequested({required this.email, required this.password});
  @override List<Object> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  const RegisterRequested({required this.name, required this.email, required this.password});
  @override List<Object> get props => [name, email, password];
}

class GoogleSignInRequested extends AuthEvent {
  const GoogleSignInRequested();
  @override List<Object> get props => [];
}

class AppleSignInRequested extends AuthEvent {
  const AppleSignInRequested();
  @override List<Object> get props => [];
}

class AuthReset extends AuthEvent {
  const AuthReset();
  @override List<Object> get props => [];
}

class ForgotPasswordRequested extends AuthEvent {
  final String email;
  const ForgotPasswordRequested({required this.email});
  @override List<Object> get props => [email];
}

class ResetPasswordRequested extends AuthEvent {
  final String newPassword;
  const ResetPasswordRequested({required this.newPassword});
  @override List<Object> get props => [newPassword];
}
