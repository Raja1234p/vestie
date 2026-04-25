import 'package:shared_preferences/shared_preferences.dart';
import '../network/dio_client.dart';
import '../storage/secure_storage_impl.dart';
import '../storage/shared_prefs_impl.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source_impl.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_use_case.dart';
import '../../features/auth/domain/usecases/register_use_case.dart';
import '../../features/auth/domain/usecases/verify_email_use_case.dart';
import '../../features/auth/domain/usecases/resend_code_use_case.dart';
import '../../features/auth/domain/usecases/forgot_password_use_case.dart';
import '../../features/auth/domain/usecases/reset_password_use_case.dart';
import '../../features/auth/domain/usecases/logout_use_case.dart';
import '../../features/auth/domain/usecases/get_me_use_case.dart';
import '../../features/auth/domain/usecases/get_risk_disclaimer_use_case.dart';
import '../../features/auth/domain/usecases/accept_risk_disclaimer_use_case.dart';
import '../../features/auth/domain/usecases/google_login_use_case.dart';

class ServiceLocator {
  ServiceLocator._();
  static final ServiceLocator instance = ServiceLocator._();

  late final DioClient dioClient;
  late final SecureStorageImpl secureStorage;
  late final SharedPrefsImpl sharedPrefs;

  // ── Auth Feature ─────────────────────────────────────────────────────────
  late final AuthRemoteDataSource authRemoteDataSource;
  late final AuthRepository authRepository;

  late final LoginUseCase loginUseCase;
  late final RegisterUseCase registerUseCase;
  late final VerifyEmailUseCase verifyEmailUseCase;
  late final ResendCodeUseCase resendCodeUseCase;
  late final ForgotPasswordUseCase forgotPasswordUseCase;
  late final ResetPasswordUseCase resetPasswordUseCase;
  late final LogoutUseCase logoutUseCase;
  late final GetMeUseCase getMeUseCase;
  late final GetRiskDisclaimerUseCase getRiskDisclaimerUseCase;
  late final AcceptRiskDisclaimerUseCase acceptRiskDisclaimerUseCase;
  late final GoogleLoginUseCase googleLoginUseCase;

  Future<void> init() async {
    // ── Core ───────────────────────────────────────────────────────────────
    final sharedPreferences = await SharedPreferences.getInstance();
    sharedPrefs = SharedPrefsImpl(sharedPreferences);
    secureStorage = SecureStorageImpl();
    dioClient = DioClient(secureStorage: secureStorage);

    // ── Auth Feature ───────────────────────────────────────────────────────
    authRemoteDataSource = AuthRemoteDataSourceImpl(dioClient);
    authRepository = AuthRepositoryImpl(authRemoteDataSource);

    loginUseCase = LoginUseCase(authRepository);
    registerUseCase = RegisterUseCase(authRepository);
    verifyEmailUseCase = VerifyEmailUseCase(authRepository);
    resendCodeUseCase = ResendCodeUseCase(authRepository);
    forgotPasswordUseCase = ForgotPasswordUseCase(authRepository);
    resetPasswordUseCase = ResetPasswordUseCase(authRepository);
    logoutUseCase = LogoutUseCase(authRepository);
    getMeUseCase = GetMeUseCase(authRepository);
    getRiskDisclaimerUseCase = GetRiskDisclaimerUseCase(authRepository);
    acceptRiskDisclaimerUseCase = AcceptRiskDisclaimerUseCase(authRepository);
    googleLoginUseCase = GoogleLoginUseCase(authRepository);
  }
}
