import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../domain/usecases/register_use_case.dart';
import '../../domain/usecases/google_login_use_case.dart';
import '../../domain/usecases/get_risk_disclaimer_use_case.dart';
import '../../../../core/constants/storage_keys.dart';
import 'register_event.dart';
import 'register_state.dart';

/// Handles registration API flow.
class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final RegisterUseCase _registerUseCase;
  final GoogleLoginUseCase _googleLoginUseCase;
  final GetRiskDisclaimerUseCase _getRiskDisclaimerUseCase;

  RegisterBloc({
    RegisterUseCase? registerUseCase,
    GoogleLoginUseCase? googleLoginUseCase,
    GetRiskDisclaimerUseCase? getRiskDisclaimerUseCase,
  })  : _registerUseCase = registerUseCase ?? ServiceLocator.instance.registerUseCase,
        _googleLoginUseCase = googleLoginUseCase ?? ServiceLocator.instance.googleLoginUseCase,
        _getRiskDisclaimerUseCase = getRiskDisclaimerUseCase ?? ServiceLocator.instance.getRiskDisclaimerUseCase,
        super(const RegisterInitial()) {
    on<RegisterSubmitted>(_onRegisterSubmitted);
    on<GoogleRegisterRequested>(_onGoogleRegisterRequested);
    on<RegisterReset>((_, emit) => emit(const RegisterInitial()));
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    emit(const RegisterLoading());

    final result = await _registerUseCase(
      fullName: event.name,
      email: event.email,
      password: event.password,
      confirmPassword: event.confirmPassword,
    );

    result.fold(
      (failure) => emit(RegisterError(message: failure.message, title: failure.title)),
      (_) => emit(RegisterSuccess(email: event.email)),
    );
  }

  Future<void> _onGoogleRegisterRequested(
    GoogleRegisterRequested event,
    Emitter<RegisterState> emit,
  ) async {
    emit(const RegisterLoading());

    final result = await _googleLoginUseCase();

    await result.fold(
      (failure) async {
        emit(RegisterError(message: failure.message, title: failure.title));
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

        emit(RegisterGoogleSuccess(isDisclaimerAccepted: isDisclaimerAccepted));
      },
    );
  }
}
