import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../../../core/device/device_info_service.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/username_input_formatter.dart';
import '../../../../core/utils/validation_utils.dart';
import '../../domain/entities/update_me_photo.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/register_result.dart';
import '../../domain/entities/verify_reset_code_result.dart';
import '../../domain/entities/risk_disclaimer.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final LocalStorage _prefs;
  final LocalStorage _secureStorage;
  final DeviceInfoService _deviceInfoService;

  /// Last GET result this process when [accepted] is not yet persisted as `true`
  /// on disk — avoids duplicate GETs (e.g. splash + agreement) in one launch.
  RiskDisclaimer? _sessionDisclaimer;

  AuthRepositoryImpl(
    this._remoteDataSource,
    this._prefs,
    this._secureStorage,
    this._deviceInfoService,
  );

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
    required String ipAddress,
  }) async {
    try {
      final device = await _deviceInfoService.getIdentity();
      final userModel = await _remoteDataSource.login(
        email: email,
        password: password,
        deviceId: device.id,
        deviceName: device.name,
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
      AppLogger.error(
        'Login Unexpected Exception',
        error: e,
        stackTrace: stack,
      );
      return const Left(
        ServerFailure('An unexpected error occurred during login'),
      );
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
      return Right(
        RegisterResult(
          userId: model.userId,
          requiresEmailVerification: model.requiresEmailVerification,
        ),
      );
    } on ServerException catch (e, stack) {
      AppLogger.error(
        'Registration Server Exception',
        error: e,
        stackTrace: stack,
      );
      return Left(ServerFailure(e.message, e.title));
    } catch (e, stack) {
      AppLogger.error(
        'Registration Unexpected Exception',
        error: e,
        stackTrace: stack,
      );
      return const Left(
        ServerFailure('An unexpected error occurred during registration'),
      );
    }
  }

  @override
  Future<Either<Failure, User>> verifyEmail({
    required String email,
    required String code,
  }) async {
    try {
      final userModel = await _remoteDataSource.verifyEmail(
        email: email,
        code: code,
      );
      return Right(userModel);
    } on ServerException catch (e, stack) {
      AppLogger.error(
        'Verify Email Server Exception',
        error: e,
        stackTrace: stack,
      );
      return Left(ServerFailure(e.message, e.title));
    } catch (e, stack) {
      AppLogger.error(
        'Verify Email Unexpected Exception',
        error: e,
        stackTrace: stack,
      );
      return const Left(
        ServerFailure('An unexpected error occurred during email verification'),
      );
    }
  }

  @override
  Future<Either<Failure, String>> resendCode({required String email}) async {
    try {
      final model = await _remoteDataSource.resendCode(email: email);
      return Right(model.message);
    } on ServerException catch (e, stack) {
      AppLogger.error(
        'Resend Code Server Exception',
        error: e,
        stackTrace: stack,
      );
      return Left(ServerFailure(e.message, e.title));
    } catch (e, stack) {
      AppLogger.error(
        'Resend Code Unexpected Exception',
        error: e,
        stackTrace: stack,
      );
      return const Left(
        ServerFailure('An unexpected error occurred while resending code'),
      );
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
      AppLogger.error(
        'Forgot Password Server Exception',
        error: e,
        stackTrace: stack,
      );
      return Left(ServerFailure(e.message, e.title));
    } catch (e, stack) {
      AppLogger.error(
        'Forgot Password Unexpected Exception',
        error: e,
        stackTrace: stack,
      );
      return const Left(
        ServerFailure(
          'An unexpected error occurred while processing forgot password request',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, VerifyResetCodeResult>> verifyResetCode({
    required String email,
    required String code,
  }) async {
    try {
      final model = await _remoteDataSource.verifyResetCode(
        email: email,
        code: code,
      );
      return Right(
        VerifyResetCodeResult(
          userId: model.userId,
          message: model.message,
        ),
      );
    } on ServerException catch (e, stack) {
      AppLogger.error(
        'Verify Reset Code Server Exception',
        error: e,
        stackTrace: stack,
      );
      return Left(ServerFailure(e.message, e.title));
    } catch (e, stack) {
      AppLogger.error(
        'Verify Reset Code Unexpected Exception',
        error: e,
        stackTrace: stack,
      );
      return const Left(
        ServerFailure('An unexpected error occurred during reset code verification'),
      );
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
      AppLogger.error(
        'Reset Password Server Exception',
        error: e,
        stackTrace: stack,
      );
      return Left(ServerFailure(e.message, e.title));
    } catch (e, stack) {
      AppLogger.error(
        'Reset Password Unexpected Exception',
        error: e,
        stackTrace: stack,
      );
      return const Left(
        ServerFailure('An unexpected error occurred while resetting password'),
      );
    }
  }

  @override
  Future<Either<Failure, String>> logout({required String refreshToken}) async {
    try {
      final model = await _remoteDataSource.logout(refreshToken: refreshToken);
      return Right(model.message);
    } on ServerException catch (e, stack) {
      AppLogger.error('Logout Server Exception', error: e, stackTrace: stack);
      return Left(ServerFailure(e.message, e.title));
    } catch (e, stack) {
      AppLogger.error(
        'Logout Unexpected Exception',
        error: e,
        stackTrace: stack,
      );
      return const Left(
        ServerFailure('An unexpected error occurred during logout'),
      );
    } finally {
      await clearRiskDisclaimerLocalCache();
    }
  }

  @override
  Future<Either<Failure, User>> getMe() async {
    try {
      final userModel = await _remoteDataSource.getMe();
      return Right(userModel);
    } on UnauthorizedException catch (e, stack) {
      AppLogger.error('GetMe Unauthorized', error: e, stackTrace: stack);
      return Left(ServerFailure(e.message, e.title));
    } on ServerException catch (e, stack) {
      AppLogger.error('GetMe Server Exception', error: e, stackTrace: stack);
      return Left(ServerFailure(e.message, e.title));
    } catch (e, stack) {
      AppLogger.error(
        'GetMe Unexpected Exception',
        error: e,
        stackTrace: stack,
      );
      return const Left(
        ServerFailure(
          'An unexpected error occurred while fetching user profile',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, User>> updateMe({
    required String firstName,
    required String lastName,
    required String userName,
    UpdateMePhoto photo = const UpdateMePhotoUnchanged(),
  }) async {
    try {
      final userModel = await _remoteDataSource.updateMe(
        firstName: firstName,
        lastName: lastName,
        userName: userName,
        photo: photo,
      );
      return Right(userModel);
    } on ServerException catch (e, stack) {
      AppLogger.error('UpdateMe Server Exception', error: e, stackTrace: stack);
      return Left(ServerFailure(e.message, e.title));
    } catch (e, stack) {
      AppLogger.error(
        'UpdateMe Unexpected Exception',
        error: e,
        stackTrace: stack,
      );
      return const Left(
        ServerFailure(
          'An unexpected error occurred while updating user profile',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, User>> deleteMeProfilePicture() async {
    try {
      final userModel = await _remoteDataSource.deleteMeProfilePicture();
      return Right(userModel);
    } on ServerException catch (e, stack) {
      AppLogger.error(
        'DeleteMeProfilePicture Server Exception',
        error: e,
        stackTrace: stack,
      );
      return Left(ServerFailure(e.message, e.title));
    } catch (e, stack) {
      AppLogger.error(
        'DeleteMeProfilePicture Unexpected Exception',
        error: e,
        stackTrace: stack,
      );
      return const Left(
        ServerFailure(
          'An unexpected error occurred while removing profile photo',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, RiskDisclaimer>> getRiskDisclaimer() async {
    try {
      final fromDisk = await _readAcceptedDisclaimerFromDisk();
      if (fromDisk != null) {
        _sessionDisclaimer = fromDisk;
        return Right(fromDisk);
      }

      if (_sessionDisclaimer != null) {
        return Right(_sessionDisclaimer!);
      }

      final model = await _remoteDataSource.getRiskDisclaimer();
      final entity = RiskDisclaimer(
        version: model.version,
        guidelines: model.guidelines,
        accepted: model.accepted,
      );
      await _persistDisclaimerSnapshot(entity);
      _sessionDisclaimer = entity;
      return Right(entity);
    } on ServerException catch (e, stack) {
      AppLogger.error(
        'Get Risk Disclaimer Server Exception',
        error: e,
        stackTrace: stack,
      );
      return Left(ServerFailure(e.message, e.title));
    } catch (e, stack) {
      AppLogger.error(
        'Get Risk Disclaimer Unexpected Exception',
        error: e,
        stackTrace: stack,
      );
      return const Left(
        ServerFailure(
          'An unexpected error occurred while checking risk disclaimer status',
        ),
      );
    }
  }

  @override
  Future<void> clearRiskDisclaimerLocalCache() async {
    _sessionDisclaimer = null;
    await _prefs.remove(StorageKeys.disclaimerAccepted);
    await _prefs.remove(StorageKeys.riskDisclaimerCachedAt);
    await _prefs.remove(StorageKeys.riskDisclaimerVersion);
    await _prefs.remove(StorageKeys.riskDisclaimerGuidelinesJson);
  }

  Future<void> _persistDisclaimerSnapshot(RiskDisclaimer d) async {
    await _prefs.saveBool(StorageKeys.disclaimerAccepted, d.accepted);
    await _prefs.saveString(
      StorageKeys.riskDisclaimerCachedAt,
      DateTime.now().toUtc().toIso8601String(),
    );
    await _prefs.saveString(StorageKeys.riskDisclaimerVersion, d.version);
    await _prefs.saveString(
      StorageKeys.riskDisclaimerGuidelinesJson,
      jsonEncode(d.guidelines),
    );
  }

  Future<RiskDisclaimer?> _readAcceptedDisclaimerFromDisk() async {
    final accepted = await _prefs.getBool(StorageKeys.disclaimerAccepted);
    if (!accepted) return null;

    final version =
        await _prefs.getString(StorageKeys.riskDisclaimerVersion) ?? '1.0';
    final raw = await _prefs.getString(
      StorageKeys.riskDisclaimerGuidelinesJson,
    );
    var guidelines = <String>[];
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          guidelines = decoded.map((e) => e.toString()).toList();
        }
      } catch (_) {}
    }
    return RiskDisclaimer(
      version: version,
      guidelines: guidelines,
      accepted: true,
    );
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
      final guidelines = _sessionDisclaimer?.guidelines ?? const <String>[];
      final accepted = RiskDisclaimer(
        version: version,
        guidelines: guidelines,
        accepted: true,
      );
      await _persistDisclaimerSnapshot(accepted);
      _sessionDisclaimer = accepted;
      return Right(model.message);
    } on ServerException catch (e, stack) {
      AppLogger.error(
        'Accept Risk Disclaimer Server Exception',
        error: e,
        stackTrace: stack,
      );
      return Left(ServerFailure(e.message, e.title));
    } catch (e, stack) {
      AppLogger.error(
        'Accept Risk Disclaimer Unexpected Exception',
        error: e,
        stackTrace: stack,
      );
      return const Left(
        ServerFailure(
          'An unexpected error occurred while accepting risk disclaimer',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, User>> loginWithGoogle() async {
    try {
      // Google Cloud Console OAuth (Web client ID set as [GoogleSignIn] serverClientId in main.dart).
      // No Firebase — backend verifies `idToken` via Google's tokeninfo / libraries.
      final googleUser = await GoogleSignIn.instance.authenticate();
      await googleUser.authorizationClient.authorizeScopes([
        'email',
        'profile',
      ]);
      final idToken = googleUser.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        return const Left(ServerFailure(AppStrings.errorGoogleSignInNoToken));
      }

      final device = await _deviceInfoService.getIdentity();
      final userModel = await _remoteDataSource.loginWithGoogle(
        idToken: idToken,
        deviceId: device.id,
        deviceName: device.name,
      );

      return Right(userModel);
    } on GoogleSignInException catch (e, stack) {
      AppLogger.error(
        'Google Sign-In platform error: ${e.code}',
        error: e.description ?? e,
        stackTrace: stack,
      );
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return const Left(SignInCanceledFailure());
      }
      return const Left(ServerFailure(AppStrings.errorGoogleSignInFailed));
    } on UnauthorizedException catch (e, stack) {
      AppLogger.error(
        'Google Sign-In Unauthorized',
        error: e,
        stackTrace: stack,
      );
      return Left(ServerFailure(e.message, e.title));
    } on ServerException catch (e, stack) {
      AppLogger.error(
        'Google Sign-In Server Exception',
        error: e,
        stackTrace: stack,
      );
      return Left(ServerFailure(e.message, e.title));
    } catch (e, stack) {
      AppLogger.error(
        'Google Sign-In Unexpected Exception',
        error: e,
        stackTrace: stack,
      );
      return const Left(ServerFailure(AppStrings.errorGoogleSignInFailed));
    }
  }

  @override
  Future<Either<Failure, User>> loginWithApple() async {
    try {
      final isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        return const Left(ServerFailure(AppStrings.errorAppleSignInFailed));
      }

      // Official scopes: email + fullName. Name/email are only in the
      // authorization response on first Apple ID ↔ app consent — never in idToken.
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      AppLogger.info(
        'Apple Sign-In credential fields: '
        'hasGivenName=${(credential.givenName ?? '').trim().isNotEmpty}, '
        'hasFamilyName=${(credential.familyName ?? '').trim().isNotEmpty}, '
        'hasEmail=${(credential.email ?? '').trim().isNotEmpty}',
      );

      // Persist immediately (Apple will not send these again).
      await _cacheApplePersonNameIfPresent(
        givenName: credential.givenName,
        familyName: credential.familyName,
      );

      final idToken = credential.identityToken;
      if (idToken == null || idToken.isEmpty) {
        return const Left(ServerFailure(AppStrings.errorAppleSignInNoToken));
      }

      final device = await _deviceInfoService.getIdentity();
      // Swagger ExternalLoginRequest: idToken + deviceName + ipAddress only
      // (additionalProperties: false) — cannot send first/last here.
      final userModel = await _remoteDataSource.loginWithApple(
        idToken: idToken,
        deviceName: device.name,
      );

      // Persist name via PUT /users/me (JSON UpdateProfileRequest).
      // Failures must not block Apple login.
      await _syncAppleNameToProfileIfNeeded(
        tokens: userModel,
        emailHint: credential.email,
      );

      return Right(userModel);
    } on SignInWithAppleAuthorizationException catch (e, stack) {
      AppLogger.error(
        'Apple Sign-In platform error: ${e.code}',
        error: e,
        stackTrace: stack,
      );
      if (e.code == AuthorizationErrorCode.canceled) {
        return const Left(SignInCanceledFailure());
      }
      return const Left(ServerFailure(AppStrings.errorAppleSignInFailed));
    } on UnauthorizedException catch (e, stack) {
      AppLogger.error(
        'Apple Sign-In Unauthorized',
        error: e,
        stackTrace: stack,
      );
      return Left(ServerFailure(e.message, e.title));
    } on ServerException catch (e, stack) {
      AppLogger.error(
        'Apple Sign-In Server Exception',
        error: e,
        stackTrace: stack,
      );
      return Left(ServerFailure(e.message, e.title));
    } catch (e, stack) {
      AppLogger.error(
        'Apple Sign-In Unexpected Exception',
        error: e,
        stackTrace: stack,
      );
      return const Left(ServerFailure(AppStrings.errorAppleSignInFailed));
    }
  }

  /// After Apple auth, fill empty `firstName`/`lastName` via `PUT /users/me`.
  ///
  /// Apple does not put the person name in the identity token. Production
  /// `POST /auth/apple` only accepts `idToken`/`deviceName`/`ipAddress`, so the
  /// client must write names with UpdateProfileRequest after login.
  ///
  /// Requires tokens in secure storage so [AuthInterceptor] can authorize.
  Future<void> _syncAppleNameToProfileIfNeeded({
    required User tokens,
    required String? emailHint,
  }) async {
    final access = tokens.accessToken?.trim() ?? '';
    if (access.isEmpty) return;

    try {
      await _secureStorage.saveString(StorageKeys.accessToken, access);
      final refresh = tokens.refreshToken?.trim() ?? '';
      if (refresh.isNotEmpty) {
        await _secureStorage.saveString(StorageKeys.refreshToken, refresh);
      }

      final resolved = await _loadCachedApplePersonName();
      final firstName = resolved.firstName;
      final lastName = resolved.lastName;
      if (firstName.isEmpty && lastName.isEmpty) {
        AppLogger.info(
          'Apple Sign-In: no givenName/familyName from Apple or cache. '
          'New Vestie account is not enough — Apple only sends the name on the '
          'first Sign in with Apple consent. Revoke under Settings → Apple ID → '
          'Sign in with Apple → Vestie, then sign in again.',
        );
        return;
      }

      final me = await _remoteDataSource.getMe();
      // Skip only when real person-name fields are already set (not userName).
      if (me.firstName.trim().isNotEmpty || me.lastName.trim().isNotEmpty) {
        AppLogger.info(
          'Apple Sign-In: profile already has first/last name — skip PUT',
        );
        await _clearApplePendingName();
        return;
      }

      var userName = _appleProfileUserName(
        existing: me.userName,
        email: me.email.isNotEmpty ? me.email : (emailHint ?? ''),
        firstNameFallback: firstName,
      );
      if (userName.isEmpty) {
        AppLogger.info(
          'Apple Sign-In: cannot resolve userName for profile PUT — abort',
        );
        return;
      }
      // Soften: still PUT names even if handle fails our UI validator.
      if (ValidationUtils.validateProfileUsernameHandle(userName) != null) {
        final fallback = _appleProfileUserName(
          existing: '',
          email: me.email.isNotEmpty ? me.email : (emailHint ?? ''),
          firstNameFallback: firstName,
        );
        if (fallback.isNotEmpty &&
            ValidationUtils.validateProfileUsernameHandle(fallback) == null) {
          userName = fallback;
        }
      }

      AppLogger.info(
        'Apple Sign-In: PUT /users/me JSON '
        'firstLen=${firstName.length} lastLen=${lastName.length} '
        'userNameLen=${userName.length}',
      );

      final updated = await _remoteDataSource.updateMeProfileJson(
        firstName: firstName,
        lastName: lastName,
        userName: UsernameInputFormatter.normalize(userName),
      );

      if (updated.firstName.trim().isEmpty && updated.lastName.trim().isEmpty) {
        AppLogger.error(
          'Apple Sign-In: PUT /users/me succeeded but first/last still empty',
        );
        return;
      }

      await _prefs.saveString(StorageKeys.userFirstName, updated.firstName);
      await _prefs.saveString(StorageKeys.userLastName, updated.lastName);
      await _prefs.saveString(StorageKeys.userName, updated.fullName);
      await _prefs.saveString(StorageKeys.userEmail, updated.email);
      await _prefs.saveString(StorageKeys.userUsername, updated.userName);
      await _clearApplePendingName();
      AppLogger.info('Apple Sign-In: profile first/last name synced');
    } catch (e, stack) {
      AppLogger.error(
        'Apple Sign-In profile name sync failed',
        error: e,
        stackTrace: stack,
      );
    }
  }

  Future<void> _cacheApplePersonNameIfPresent({
    required String? givenName,
    required String? familyName,
  }) async {
    final first = (givenName ?? '').trim();
    final last = (familyName ?? '').trim();
    if (first.isNotEmpty) {
      await _prefs.saveString(StorageKeys.applePendingFirstName, first);
    }
    if (last.isNotEmpty) {
      await _prefs.saveString(StorageKeys.applePendingLastName, last);
    }
  }

  Future<({String firstName, String lastName})> _loadCachedApplePersonName() async {
    final first =
        (await _prefs.getString(StorageKeys.applePendingFirstName) ?? '')
            .trim();
    final last = (await _prefs.getString(StorageKeys.applePendingLastName) ?? '')
        .trim();
    return (firstName: first, lastName: last);
  }

  Future<void> _clearApplePendingName() async {
    await _prefs.remove(StorageKeys.applePendingFirstName);
    await _prefs.remove(StorageKeys.applePendingLastName);
  }

  String _appleProfileUserName({
    required String existing,
    required String email,
    String firstNameFallback = '',
  }) {
    final handle = UsernameInputFormatter.normalize(existing);
    if (handle.isNotEmpty) return handle;

    final at = email.trim().indexOf('@');
    if (at > 0) {
      return UsernameInputFormatter.normalize(email.trim().substring(0, at));
    }

    final fromFirst = UsernameInputFormatter.normalize(firstNameFallback);
    return fromFirst;
  }
}
