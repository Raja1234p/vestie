import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../entities/register_result.dart';
import '../entities/risk_disclaimer.dart';

/// Contract for auth data operations.
abstract class AuthRepository {
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
    required String deviceName,
    required String ipAddress,
  });

  Future<Either<Failure, RegisterResult>> register({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  });

  Future<Either<Failure, User>> verifyEmail({
    required String email,
    required String code,
  });

  Future<Either<Failure, String>> resendCode({
    required String email,
  });

  Future<Either<Failure, String>> forgotPassword({
    required String email,
  });

  Future<Either<Failure, String>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
    required String confirmNewPassword,
  });

  Future<Either<Failure, String>> logout({
    required String refreshToken,
  });

  Future<Either<Failure, User>> getMe();

  Future<Either<Failure, RiskDisclaimer>> getRiskDisclaimer();

  Future<Either<Failure, String>> acceptRiskDisclaimer({
    required String version,
    required String ipAddress,
  });

  Future<Either<Failure, User>> loginWithGoogle();

  Future<Either<Failure, void>> loginWithApple();
}
