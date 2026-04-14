import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

// ─── Auth States ────────────────────────────────────────────────────────────
abstract class AuthState extends Equatable {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
  @override List<Object> get props => [];
}

class AuthLoading extends AuthState {
  const AuthLoading();
  @override List<Object> get props => [];
}

/// Emitted after successful LOGIN — carry user to Dashboard
class AuthLoginSuccess extends AuthState {
  final User user;
  const AuthLoginSuccess({required this.user});
  @override List<Object> get props => [user];
}

/// Emitted after successful REGISTER — carry email for OTP verification
class AuthRegistered extends AuthState {
  final String email;
  const AuthRegistered({required this.email});
  @override List<Object> get props => [email];
}

/// Any auth failure
class AuthError extends AuthState {
  final String message;
  const AuthError({required this.message});
  @override List<Object> get props => [message];
}

/// Emitted after sending forgot-password email
class AuthForgotSent extends AuthState {
  const AuthForgotSent();
  @override List<Object> get props => [];
}

/// Emitted after successful password reset
class AuthPasswordReset extends AuthState {
  const AuthPasswordReset();
  @override List<Object> get props => [];
}
