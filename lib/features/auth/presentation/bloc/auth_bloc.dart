import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/user.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// WHY BLoC (not Cubit):
/// Auth has multiple distinct event types (Login, Register, Google, Apple)
/// each with different payloads and state transitions. BLoC's explicit event
/// classes make the flow auditable, testable, and extensible when real API
/// handlers are plugged in.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<GoogleSignInRequested>(_onGoogleSignIn);
    on<AppleSignInRequested>(_onAppleSignIn);
    on<ForgotPasswordRequested>(_onForgotPassword);
    on<ResetPasswordRequested>(_onResetPassword);
    on<AuthReset>((_, emit) => emit(const AuthInitial()));
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    await Future.delayed(const Duration(milliseconds: 1200)); // Stub API delay
    // TODO: Replace with real AuthRepository.login()
    const mockUser = User(id: '1', name: 'Vestie User', email: 'user@vestie.app');
    emit(const AuthLoginSuccess(user: mockUser));
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    await Future.delayed(const Duration(milliseconds: 1200)); // Stub API delay
    // TODO: Replace with real AuthRepository.register()
    emit(AuthRegistered(email: event.email));
  }

  Future<void> _onGoogleSignIn(
    GoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    await Future.delayed(const Duration(milliseconds: 600));
    emit(const AuthError(message: AppStrings.socialComingSoon));
  }

  Future<void> _onAppleSignIn(
    AppleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    await Future.delayed(const Duration(milliseconds: 600));
    emit(const AuthError(message: AppStrings.socialComingSoon));
  }

  Future<void> _onForgotPassword(
    ForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    await Future.delayed(const Duration(milliseconds: 1000));
    // TODO: Replace with real AuthRepository.sendPasswordResetEmail()
    emit(const AuthForgotSent());
  }

  Future<void> _onResetPassword(
    ResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    await Future.delayed(const Duration(milliseconds: 1000));
    // TODO: Replace with real AuthRepository.resetPassword()
    emit(const AuthPasswordReset());
  }
}
