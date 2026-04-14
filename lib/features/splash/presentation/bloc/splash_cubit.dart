import 'package:flutter_bloc/flutter_bloc.dart';

/// Splash State Definitions
abstract class SplashState {}

class SplashInitial extends SplashState {}
class SplashLoading extends SplashState {}
class SplashCompleted extends SplashState {
  final bool isAuthenticated;
  SplashCompleted({required this.isAuthenticated});
}

/// BLoC orchestrating the initial loading logic (validating tokens, caching, etc.)
class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(SplashInitial());

  Future<void> initializeApp() async {
    emit(SplashLoading());
    
    // // Simulate complex app initialization (e.g., checking secure storage for JWT)
    await Future.delayed(const Duration(seconds: 3));
    
    // Hardcoded to false for now so it routes to Auth/Login screen next
    emit(SplashCompleted(isAuthenticated: false));
  }
}
