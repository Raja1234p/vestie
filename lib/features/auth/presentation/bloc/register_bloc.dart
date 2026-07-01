import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/failure_mapper.dart';
import '../../../../core/utils/validation_utils.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/register_use_case.dart';
import '../../domain/usecases/apple_login_use_case.dart';
import '../../domain/usecases/google_login_use_case.dart';
import '../../domain/usecases/get_risk_disclaimer_use_case.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../../../core/storage/onboarding_prefs.dart';
import 'register_event.dart';
import 'register_state.dart';

/// Handles registration API flow.
class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final RegisterUseCase _registerUseCase;
  final GoogleLoginUseCase _googleLoginUseCase;
  final AppleLoginUseCase _appleLoginUseCase;
  final GetRiskDisclaimerUseCase _getRiskDisclaimerUseCase;

  RegisterBloc({
    RegisterUseCase? registerUseCase,
    GoogleLoginUseCase? googleLoginUseCase,
    AppleLoginUseCase? appleLoginUseCase,
    GetRiskDisclaimerUseCase? getRiskDisclaimerUseCase,
  }) : _registerUseCase =
           registerUseCase ?? ServiceLocator.instance.registerUseCase,
       _googleLoginUseCase =
           googleLoginUseCase ?? ServiceLocator.instance.googleLoginUseCase,
       _appleLoginUseCase =
           appleLoginUseCase ?? ServiceLocator.instance.appleLoginUseCase,
       _getRiskDisclaimerUseCase =
           getRiskDisclaimerUseCase ??
           ServiceLocator.instance.getRiskDisclaimerUseCase,
       super(const RegisterInitial()) {
    on<RegisterSubmitted>(_onRegisterSubmitted);
    on<GoogleRegisterRequested>(_onGoogleRegisterRequested);
    on<AppleRegisterRequested>(_onAppleRegisterRequested);
    on<RegisterReset>((_, emit) => emit(const RegisterInitial()));
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    final hasErrors =
        ValidationUtils.validateFullName(event.name) != null ||
        ValidationUtils.validateEmail(event.email) != null ||
        ValidationUtils.validatePassword(event.password) != null ||
        ValidationUtils.validateConfirmPassword(
              event.confirmPassword,
              event.password,
            ) !=
            null;
    if (hasErrors) return;

    emit(const RegisterLoading());

    final result = await _registerUseCase(
      fullName: event.name,
      email: event.email,
      password: event.password,
      confirmPassword: event.confirmPassword,
    );

    result.fold(
      (failure) =>
          emit(RegisterError(message: failure.message, title: failure.title)),
      (_) => emit(
        RegisterSuccess(
          user: User(
            id: '',
            name: event.name,
            email: event.email,
            userName: '',
          ),
        ),
      ),
    );
  }

  Future<void> _onGoogleRegisterRequested(
    GoogleRegisterRequested event,
    Emitter<RegisterState> emit,
  ) async {
    emit(const RegisterGoogleLoading());

    final result = await _googleLoginUseCase();

    await result.fold(
      (failure) async {
        if (failure is SignInCanceledFailure) {
          emit(const RegisterInitial());
          return;
        }
        emit(
          RegisterError(
            message: FailureMapper.userMessage(failure),
            title: FailureMapper.dialogTitle(failure),
          ),
        );
      },
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

        // Check Risk Disclaimer status
        final disclaimerResult = await _getRiskDisclaimerUseCase();
        final isDisclaimerAccepted = disclaimerResult.fold(
          (_) => false,
          (disclaimer) => disclaimer.accepted,
        );

        await OnboardingPrefs.markCompleted();
        emit(RegisterGoogleSuccess(isDisclaimerAccepted: isDisclaimerAccepted));
      },
    );
  }

  Future<void> _onAppleRegisterRequested(
    AppleRegisterRequested event,
    Emitter<RegisterState> emit,
  ) async {
    emit(const RegisterAppleLoading());

    final result = await _appleLoginUseCase();

    await result.fold(
      (failure) async {
        if (failure is SignInCanceledFailure) {
          emit(const RegisterInitial());
          return;
        }
        emit(
          RegisterError(
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
        emit(RegisterAppleSuccess(isDisclaimerAccepted: isDisclaimerAccepted));
      },
    );
  }
}
