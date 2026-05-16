import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../../../core/storage/onboarding_prefs.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/bloc/form_submission_state.dart';
import '../../../../core/bloc/base_form_bloc.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/usecases/login_use_case.dart';
import '../../domain/usecases/google_login_use_case.dart';
import '../../domain/usecases/get_risk_disclaimer_use_case.dart';
import '../../domain/entities/user.dart';
import 'login_event.dart';
import 'login_state.dart';

/// Handles login API flow.
class LoginBloc extends BaseFormBloc<LoginEvent, LoginState> {
  final LoginUseCase _loginUseCase;
  final GoogleLoginUseCase _googleLoginUseCase;
  final GetRiskDisclaimerUseCase _getRiskDisclaimerUseCase;

  LoginBloc({
    LoginUseCase? loginUseCase,
    GoogleLoginUseCase? googleLoginUseCase,
    GetRiskDisclaimerUseCase? getRiskDisclaimerUseCase,
  })  : _loginUseCase = loginUseCase ?? ServiceLocator.instance.loginUseCase,
        _googleLoginUseCase = googleLoginUseCase ?? ServiceLocator.instance.googleLoginUseCase,
        _getRiskDisclaimerUseCase = getRiskDisclaimerUseCase ?? ServiceLocator.instance.getRiskDisclaimerUseCase,
        super(const LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<GoogleLoginRequested>(_onGoogleLoginRequested);
    on<LoginReset>((_, emit) => emit(const LoginInitial()));
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    final emailError = Validators.validateEmail(event.email);
    if (emailError != null) {
      emit(LoginError(message: 'Validation Error', validationErrors: {'email': emailError}));
      return;
    }

    await executeSubmission<User>(
      () => _loginUseCase(
        email: event.email,
        password: event.password,
        deviceName: ApiConstants.defaultDeviceName,
        ipAddress: ApiConstants.defaultIpAddress,
      ),
      emit,
      stateBuilder: (status, errorMessage, errorTitle, errors, user) {
        if (status == FormSubmissionStatus.submitting) return const LoginLoading();
        if (status == FormSubmissionStatus.failure) {
          return LoginError(
            message: errorMessage ?? 'Error',
            title: errorTitle,
            validationErrors: errors,
          );
        }
        return const LoginLoading(); // Temporarily loading while resolving disclaimer
      },
    );

    if (state is LoginError) return;

    // Resolve success explicitly since we need the disclaimer
    final result = await _loginUseCase(
      email: event.email,
      password: event.password,
      deviceName: ApiConstants.defaultDeviceName,
      ipAddress: ApiConstants.defaultIpAddress,
    );

    await result.fold(
      (failure) async {},
      (user) async {
        // Save tokens
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

          // Check Risk Disclaimer status
          final disclaimerResult = await _getRiskDisclaimerUseCase();
          final isDisclaimerAccepted = disclaimerResult.fold(
            (_) => false,
            (disclaimer) => disclaimer.accepted,
          );

          await OnboardingPrefs.markCompleted();
          emit(LoginSuccess(user: user, isDisclaimerAccepted: isDisclaimerAccepted));
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
        emit(LoginError(message: failure.message, title: failure.title));
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
}
