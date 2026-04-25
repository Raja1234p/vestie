import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../../../core/di/service_locator.dart';
import '../../domain/usecases/login_use_case.dart';
import '../../domain/usecases/google_login_use_case.dart';
import '../../domain/usecases/get_risk_disclaimer_use_case.dart';
import 'login_event.dart';
import 'login_state.dart';

/// Handles login API flow.
class LoginBloc extends Bloc<LoginEvent, LoginState> {
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
    emit(const LoginLoading());

    final result = await _loginUseCase(
      email: event.email,
      password: event.password,
      deviceName: ApiConstants.defaultDeviceName,
      ipAddress: ApiConstants.defaultIpAddress,
    );

    await result.fold(
      (failure) async {
        emit(LoginError(message: failure.message, title: failure.title));
      },
      (user) async {
        // Save tokens
        if (user.accessToken != null) {
          await ServiceLocator.instance.secureStorage.saveString(
            StorageKeys.accessToken,
            user.accessToken!,
          );
        }
        if (user.refreshToken != null) {
          await ServiceLocator.instance.secureStorage.saveString(
            StorageKeys.refreshToken,
            user.refreshToken!,
          );
        }
          await ServiceLocator.instance.sharedPrefs.saveBool(
            StorageKeys.isLoggedIn,
            true,
          );

          // Check Risk Disclaimer status
          final disclaimerResult = await _getRiskDisclaimerUseCase();
          final isDisclaimerAccepted = disclaimerResult.fold(
            (_) => false,
            (disclaimer) => disclaimer.accepted,
          );

          emit(LoginSuccess(user: user, isDisclaimerAccepted: isDisclaimerAccepted));
        },
      );
    }

  Future<void> _onGoogleLoginRequested(
    GoogleLoginRequested event,
    Emitter<LoginState> emit,
  ) async {
    emit(const LoginLoading());

    final result = await _googleLoginUseCase();

    await result.fold(
      (failure) async {
        emit(LoginError(message: failure.message, title: failure.title));
      },
      (user) async {
        // Save tokens
        if (user.accessToken != null) {
          await ServiceLocator.instance.secureStorage.saveString(
            StorageKeys.accessToken,
            user.accessToken!,
          );
        }
        if (user.refreshToken != null) {
          await ServiceLocator.instance.secureStorage.saveString(
            StorageKeys.refreshToken,
            user.refreshToken!,
          );
        }
          await ServiceLocator.instance.sharedPrefs.saveBool(
            StorageKeys.isLoggedIn,
            true,
          );

          // Check Risk Disclaimer status
          final disclaimerResult = await _getRiskDisclaimerUseCase();
          final isDisclaimerAccepted = disclaimerResult.fold(
            (_) => false,
            (disclaimer) => disclaimer.accepted,
          );

          emit(LoginSuccess(user: user, isDisclaimerAccepted: isDisclaimerAccepted));
        },
      );
    }
  }
