import '../../features/auth/data/datasources/auth_remote_data_source_impl.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/usecases/accept_risk_disclaimer_use_case.dart';
import '../../features/auth/domain/usecases/delete_me_profile_picture_use_case.dart';
import '../../features/auth/domain/usecases/forgot_password_use_case.dart';
import '../../features/auth/domain/usecases/get_me_use_case.dart';
import '../../features/auth/domain/usecases/get_risk_disclaimer_use_case.dart';
import '../../features/auth/domain/usecases/apple_login_use_case.dart';
import '../../features/auth/domain/usecases/google_login_use_case.dart';
import '../../features/auth/domain/usecases/login_use_case.dart';
import '../../features/auth/domain/usecases/logout_use_case.dart';
import '../../features/auth/domain/usecases/register_use_case.dart';
import '../../features/auth/domain/usecases/resend_code_use_case.dart';
import '../../features/auth/domain/usecases/reset_password_use_case.dart';
import '../../features/auth/domain/usecases/update_me_use_case.dart';
import '../../features/auth/domain/usecases/verify_email_use_case.dart';
import '../../features/auth/domain/usecases/verify_reset_code_use_case.dart';
import 'service_locator.dart';

/// Registers auth data sources, repository, and use cases.
void registerAuthDependencies(ServiceLocator sl) {
  sl.authRemoteDataSource = AuthRemoteDataSourceImpl(sl.dioClient);
  sl.authRepository = AuthRepositoryImpl(
    sl.authRemoteDataSource,
    sl.sharedPrefs,
    sl.deviceInfoService,
  );

  sl.loginUseCase = LoginUseCase(sl.authRepository);
  sl.registerUseCase = RegisterUseCase(sl.authRepository);
  sl.verifyEmailUseCase = VerifyEmailUseCase(sl.authRepository);
  sl.verifyResetCodeUseCase = VerifyResetCodeUseCase(sl.authRepository);
  sl.resendCodeUseCase = ResendCodeUseCase(sl.authRepository);
  sl.forgotPasswordUseCase = ForgotPasswordUseCase(sl.authRepository);
  sl.resetPasswordUseCase = ResetPasswordUseCase(sl.authRepository);
  sl.logoutUseCase = LogoutUseCase(sl.authRepository);
  sl.getMeUseCase = GetMeUseCase(sl.authRepository);
  sl.getRiskDisclaimerUseCase = GetRiskDisclaimerUseCase(sl.authRepository);
  sl.acceptRiskDisclaimerUseCase = AcceptRiskDisclaimerUseCase(
    sl.authRepository,
  );
  sl.googleLoginUseCase = GoogleLoginUseCase(sl.authRepository);
  sl.appleLoginUseCase = AppleLoginUseCase(sl.authRepository);
  sl.updateMeUseCase = UpdateMeUseCase(sl.authRepository);
  sl.deleteMeProfilePictureUseCase = DeleteMeProfilePictureUseCase(
    sl.authRepository,
  );
}
