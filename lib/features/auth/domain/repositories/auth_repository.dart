import '../entities/user.dart';

/// Contract for auth data operations.
/// Data layer must implement this; presentation only depends on this interface.
abstract class AuthRepository {
  Future<User> login({required String email, required String password});
  Future<User> register({required String name, required String email, required String password});
  Future<void> verifyOtp({required String email, required String code});
  Future<void> resendOtp({required String email});
  Future<void> loginWithGoogle();
  Future<void> loginWithApple();
}
