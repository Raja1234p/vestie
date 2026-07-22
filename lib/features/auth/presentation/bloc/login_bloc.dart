import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../../../core/storage/onboarding_prefs.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/failure_mapper.dart';
import '../../../../core/bloc/base_form_bloc.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/usecases/login_use_case.dart';
import '../../domain/usecases/apple_login_use_case.dart';
import '../../domain/usecases/google_login_use_case.dart';
import '../../domain/usecases/get_risk_disclaimer_use_case.dart';
import '../../domain/usecases/resend_code_use_case.dart';
import 'login_event.dart';
import 'login_state.dart';

/// Handles login API flow.
class LoginBloc extends BaseFormBloc<LoginEvent, LoginState> {
  final LoginUseCase _loginUseCase;
  final GoogleLoginUseCase _googleLoginUseCase;
  final AppleLoginUseCase _appleLoginUseCase;
  final GetRiskDisclaimerUseCase _getRiskDisclaimerUseCase;
  final ResendCodeUseCase _resendCodeUseCase;

  LoginBloc({
    LoginUseCase? loginUseCase,
    GoogleLoginUseCase? googleLoginUseCase,
    AppleLoginUseCase? appleLoginUseCase,
    GetRiskDisclaimerUseCase? getRiskDisclaimerUseCase,
    ResendCodeUseCase? resendCodeUseCase,
  }) : _loginUseCase = loginUseCase ?? ServiceLocator.instance.loginUseCase,
       _googleLoginUseCase =
           googleLoginUseCase ?? ServiceLocator.instance.googleLoginUseCase,
       _appleLoginUseCase =
           appleLoginUseCase ?? ServiceLocator.instance.appleLoginUseCase,
       _getRiskDisclaimerUseCase =
           getRiskDisclaimerUseCase ??
           ServiceLocator.instance.getRiskDisclaimerUseCase,
       _resendCodeUseCase =
           resendCodeUseCase ?? ServiceLocator.instance.resendCodeUseCase,
       super(const LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<GoogleLoginRequested>(_onGoogleLoginRequested);
    on<AppleLoginRequested>(_onAppleLoginRequested);
    on<LoginReset>((_, emit) => emit(const LoginInitial()));
  }

  /// Backend `400` ProblemDetails: title `Email not verified`.
  static bool isEmailNotVerifiedFailure(Failure failure) {
    final title = (failure.title ?? '').trim().toLowerCase();
    final message = failure.message.trim().toLowerCase();
    if (title == 'email not verified') return true;
    if (title.contains('email not verified')) return true;
    if (message.contains('verify your email before logging in')) return true;
    if (message.contains('email not verified')) return true;
    return false;
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    final emailError = Validators.validateEmail(event.email);
    if (emailError != null) {
      emit(
        LoginError(
          message: 'Validation Error',
          validationErrors: {'email': emailError},
        ),
      );
      return;
    }

    if (state is LoginLoading) return;
    emit(const LoginLoading());

    final email = event.email.trim();
    final result = await _loginUseCase(
      email: email,
      password: event.password,
      ipAddress: ApiConstants.defaultIpAddress,
    );

    await result.fold(
      (failure) async {
        if (isEmailNotVerifiedFailure(failure)) {
          // Same OTP path as register — send/resend code then open verify.
          await _resendCodeUseCase(email: email);
          if (!isClosed) {
            emit(LoginEmailNotVerified(email: email));
          }
          return;
        }
        emit(
          LoginError(
            message: FailureMapper.userMessage(failure),
            title: FailureMapper.dialogTitle(failure),
          ),
        );
      },
      (user) async {
        if (user.accessToken != null) {
          await ServiceLocator.instance.secureStorage.saveString(
            StorageKeys.accessToken,
            user.accessToken!,
          );
        }
        if (user.refreshToken != null && user.refreshToken!.isNotEmpty) {
          await ServiceLocator.instance.secureStorage.saveString(
            StorageKeys.refreshToken,
            user.refreshToken!,
          );
        }
        await ServiceLocator.instance.sharedPrefs.saveBool(
          StorageKeys.isLoggedIn,
          true,
        );
        await ServiceLocator.instance.sharedPrefs.saveString(
          StorageKeys.userName,
          user.name,
        );
        await ServiceLocator.instance.sharedPrefs.saveString(
          StorageKeys.userEmail,
          user.email,
        );

        final disclaimerResult = await _getRiskDisclaimerUseCase();
        final isDisclaimerAccepted = disclaimerResult.fold(
          (_) => false,
          (disclaimer) => disclaimer.accepted,
        );

        await OnboardingPrefs.markCompleted();
        emit(
          LoginSuccess(user: user, isDisclaimerAccepted: isDisclaimerAccepted),
        );
      },
    );
  }

  Future<void> _onGoogleLoginRequested(
    GoogleLoginRequested event,
    Emitter<LoginState> emit,
  ) async {
    emit(const LoginGoogleLoading());

    final result = await _googleLoginUseCase();

    await result.fold(
      (failure) async {
        if (failure is SignInCanceledFailure) {
          emit(const LoginInitial());
          return;
        }
        emit(
          LoginError(
            message: FailureMapper.userMessage(failure),
            title: FailureMapper.dialogTitle(failure),
          ),
        );
      },
      (user) async {
        if (user.accessToken != null) {
          await ServiceLocator.instance.secureStorage.saveString(
            StorageKeys.accessToken,
            user.accessToken!,
          );
        }
        if (user.refreshToken != null && user.refreshToken!.isNotEmpty) {
          await ServiceLocator.instance.secureStorage.saveString(
            StorageKeys.refreshToken,
            user.refreshToken!,
          );
        }
        await ServiceLocator.instance.sharedPrefs.saveBool(
          StorageKeys.isLoggedIn,
          true,
        );

        final disclaimerResult = await _getRiskDisclaimerUseCase();
        final isDisclaimerAccepted = disclaimerResult.fold(
          (_) => false,
          (disclaimer) => disclaimer.accepted,
        );

        await OnboardingPrefs.markCompleted();
        emit(LoginGoogleSuccess(isDisclaimerAccepted: isDisclaimerAccepted));
      },
    );
  }

  Future<void> _onAppleLoginRequested(
    AppleLoginRequested event,
    Emitter<LoginState> emit,
  ) async {
    // Keep this state through Apple sheet + /auth/apple + optional GET/PUT /users/me
    // + risk disclaimer so the Apple button / overlay stay loading.
    if (state is LoginAppleLoading) return;
    emit(const LoginAppleLoading());

    final result = await _appleLoginUseCase();

    await result.fold(
      (failure) async {
        if (failure is SignInCanceledFailure) {
          emit(const LoginInitial());
          return;
        }
        emit(
          LoginError(
            message: FailureMapper.userMessage(failure),
            title: FailureMapper.dialogTitle(failure),
          ),
        );
      },
      (user) async {
        if (user.accessToken != null) {
          await ServiceLocator.instance.secureStorage.saveString(
            StorageKeys.accessToken,
            user.accessToken!,
          );
        }
        if (user.refreshToken != null && user.refreshToken!.isNotEmpty) {
          await ServiceLocator.instance.secureStorage.saveString(
            StorageKeys.refreshToken,
            user.refreshToken!,
          );
        }
        await ServiceLocator.instance.sharedPrefs.saveBool(
          StorageKeys.isLoggedIn,
          true,
        );

        final disclaimerResult = await _getRiskDisclaimerUseCase();
        final isDisclaimerAccepted = disclaimerResult.fold(
          (_) => false,
          (disclaimer) => disclaimer.accepted,
        );

        await OnboardingPrefs.markCompleted();
        emit(LoginAppleSuccess(isDisclaimerAccepted: isDisclaimerAccepted));
      },
    );
  }
}
