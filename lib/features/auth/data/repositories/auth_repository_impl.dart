import 'package:dartz/dartz.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/register_result.dart';
import '../../domain/entities/risk_disclaimer.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
    required String deviceName,
    required String ipAddress,
  }) async {
    try {
      final userModel = await _remoteDataSource.login(
        email: email,
        password: password,
        deviceName: deviceName,
        ipAddress: ipAddress,
      );
      return Right(userModel);
    } on UnauthorizedException catch (e, stack) {
      AppLogger.error('Login Unauthorized', error: e, stackTrace: stack);
      return Left(ServerFailure(e.message, e.title));
    } on ServerException catch (e, stack) {
      AppLogger.error('Login Server Exception', error: e, stackTrace: stack);
      return Left(ServerFailure(e.message, e.title));
    } catch (e, stack) {
      AppLogger.error('Login Unexpected Exception', error: e, stackTrace: stack);
      return const Left(ServerFailure('An unexpected error occurred during login'));
    }
  }

  @override
  Future<Either<Failure, RegisterResult>> register({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final model = await _remoteDataSource.register(
        fullName: fullName,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );
      return Right(RegisterResult(
        userId: model.userId,
        requiresEmailVerification: model.requiresEmailVerification,
      ));
    } on ServerException catch (e, stack) {
      AppLogger.error('Registration Server Exception', error: e, stackTrace: stack);
      return Left(ServerFailure(e.message, e.title));
    } catch (e, stack) {
      AppLogger.error('Registration Unexpected Exception', error: e, stackTrace: stack);
      return const Left(ServerFailure('An unexpected error occurred during registration'));
    }
  }

  @override
  Future<Either<Failure, User>> verifyEmail({
    required String email,
    required String code,
  }) async {
    try {
      final userModel = await _remoteDataSource.verifyEmail(email: email, code: code);
      return Right(userModel);
    } on ServerException catch (e, stack) {
      AppLogger.error('Verify Email Server Exception', error: e, stackTrace: stack);
      return Left(ServerFailure(e.message, e.title));
    } catch (e, stack) {
      AppLogger.error('Verify Email Unexpected Exception', error: e, stackTrace: stack);
      return const Left(ServerFailure('An unexpected error occurred during email verification'));
    }
  }

  @override
  Future<Either<Failure, String>> resendCode({
    required String email,
  }) async {
    try {
      final model = await _remoteDataSource.resendCode(email: email);
      return Right(model.message);
    } on ServerException catch (e, stack) {
      AppLogger.error('Resend Code Server Exception', error: e, stackTrace: stack);
      return Left(ServerFailure(e.message, e.title));
    } catch (e, stack) {
      AppLogger.error('Resend Code Unexpected Exception', error: e, stackTrace: stack);
      return const Left(ServerFailure('An unexpected error occurred while resending code'));
    }
  }

  @override
  Future<Either<Failure, String>> forgotPassword({
    required String email,
  }) async {
    try {
      final model = await _remoteDataSource.forgotPassword(email: email);
      return Right(model.message);
    } on ServerException catch (e, stack) {
      AppLogger.error('Forgot Password Server Exception', error: e, stackTrace: stack);
      return Left(ServerFailure(e.message, e.title));
    } catch (e, stack) {
      AppLogger.error('Forgot Password Unexpected Exception', error: e, stackTrace: stack);
      return const Left(ServerFailure('An unexpected error occurred while processing forgot password request'));
    }
  }

  @override
  Future<Either<Failure, String>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    try {
      final model = await _remoteDataSource.resetPassword(
        email: email,
        code: code,
        newPassword: newPassword,
        confirmNewPassword: confirmNewPassword,
      );
      return Right(model.message);
    } on ServerException catch (e, stack) {
      AppLogger.error('Reset Password Server Exception', error: e, stackTrace: stack);
      return Left(ServerFailure(e.message, e.title));
    } catch (e, stack) {
      AppLogger.error('Reset Password Unexpected Exception', error: e, stackTrace: stack);
      return const Left(ServerFailure('An unexpected error occurred while resetting password'));
    }
  }

  @override
  Future<Either<Failure, String>> logout({
    required String refreshToken,
  }) async {
    try {
      final model = await _remoteDataSource.logout(refreshToken: refreshToken);
      return Right(model.message);
    } on ServerException catch (e, stack) {
      AppLogger.error('Logout Server Exception', error: e, stackTrace: stack);
      return Left(ServerFailure(e.message, e.title));
    } catch (e, stack) {
      AppLogger.error('Logout Unexpected Exception', error: e, stackTrace: stack);
      return const Left(ServerFailure('An unexpected error occurred during logout'));
    }
  }

  @override
  Future<Either<Failure, User>> getMe() async {
    try {
      final userModel = await _remoteDataSource.getMe();
      return Right(userModel);
    } on ServerException catch (e, stack) {
      AppLogger.error('GetMe Server Exception', error: e, stackTrace: stack);
      return Left(ServerFailure(e.message, e.title));
    } catch (e, stack) {
      AppLogger.error('GetMe Unexpected Exception', error: e, stackTrace: stack);
      return const Left(ServerFailure('An unexpected error occurred while fetching user profile'));
    }
  }

  @override
  Future<Either<Failure, User>> updateMe({
    required String firstName,
    required String lastName,
    required String userName,
    required String photoUrl,
  }) async {
    try {
      final userModel = await _remoteDataSource.updateMe(
        firstName: firstName,
        lastName: lastName,
        userName: userName,
        photoUrl: photoUrl,
      );
      return Right(userModel);
    } on ServerException catch (e, stack) {
      AppLogger.error('UpdateMe Server Exception', error: e, stackTrace: stack);
      return Left(ServerFailure(e.message, e.title));
    } catch (e, stack) {
      AppLogger.error('UpdateMe Unexpected Exception', error: e, stackTrace: stack);
      return const Left(ServerFailure('An unexpected error occurred while updating user profile'));
    }
  }

  @override
  Future<Either<Failure, RiskDisclaimer>> getRiskDisclaimer() async {
    try {
      final model = await _remoteDataSource.getRiskDisclaimer();
      return Right(RiskDisclaimer(
        version: model.version,
        guidelines: model.guidelines,
        accepted: model.accepted,
      ));
    } on ServerException catch (e, stack) {
      AppLogger.error('Get Risk Disclaimer Server Exception', error: e, stackTrace: stack);
      return Left(ServerFailure(e.message, e.title));
    } catch (e, stack) {
      AppLogger.error('Get Risk Disclaimer Unexpected Exception', error: e, stackTrace: stack);
      return const Left(ServerFailure('An unexpected error occurred while checking risk disclaimer status'));
    }
  }

  @override
  Future<Either<Failure, String>> acceptRiskDisclaimer({
    required String version,
    required String ipAddress,
  }) async {
    try {
      final model = await _remoteDataSource.acceptRiskDisclaimer(
        version: version,
        ipAddress: ipAddress,
      );
      return Right(model.message);
    } on ServerException catch (e, stack) {
      AppLogger.error('Accept Risk Disclaimer Server Exception', error: e, stackTrace: stack);
      return Left(ServerFailure(e.message, e.title));
    } catch (e, stack) {
      AppLogger.error('Accept Risk Disclaimer Unexpected Exception', error: e, stackTrace: stack);
      return const Left(ServerFailure('An unexpected error occurred while accepting risk disclaimer'));
    }
  }

  @override
  Future<Either<Failure, User>> loginWithGoogle() async {
    try {
      // Google Cloud Console OAuth (Web client ID set as [GoogleSignIn] serverClientId in main.dart).
      // No Firebase — backend verifies `idToken` via Google's tokeninfo / libraries.
      final googleUser = await GoogleSignIn.instance.authenticate();
      await googleUser.authorizationClient
          .authorizeScopes(['email', 'profile']);
      final idToken = googleUser.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        return const Left(ServerFailure('Failed to get Google ID token'));
      }

      final userModel = await _remoteDataSource.loginWithGoogle(
        idToken: idToken,
      );

      return Right(userModel);
    } on GoogleSignInException catch (e, stack) {
      AppLogger.error('Google Sign-In platform error: ${e.code}', error: e, stackTrace: stack);
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return Left(ServerFailure(AppStrings.errorGoogleSignInCanceledLikelyConfig));
      }
      return Left(ServerFailure(e.description ?? e.toString()));
    } on UnauthorizedException catch (e, stack) {
      AppLogger.error('Google Sign-In Unauthorized', error: e, stackTrace: stack);
      return Left(ServerFailure(e.message, e.title));
    } on ServerException catch (e, stack) {
      AppLogger.error('Google Sign-In Server Exception', error: e, stackTrace: stack);
      return Left(ServerFailure(e.message, e.title));
    } catch (e, stack) {
      AppLogger.error('Google Sign-In Unexpected Exception', error: e, stackTrace: stack);
      return const Left(ServerFailure('An unexpected error occurred during Google sign-in'));
    }
  }

  @override
  Future<Either<Failure, void>> loginWithApple() async {
    // TODO: Implement Apple Sign-In logic and then call API
    return const Left(ServerFailure('Apple sign-in coming soon.'));
  }
}
