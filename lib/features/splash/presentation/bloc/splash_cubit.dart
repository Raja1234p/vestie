import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../../../core/di/service_locator.dart';

/// Splash State Definitions
abstract class SplashState {}

class SplashInitial extends SplashState {}
class SplashLoading extends SplashState {}
class SplashCompleted extends SplashState {
  final bool isAuthenticated;
  final bool isDisclaimerAccepted;
  SplashCompleted({
    required this.isAuthenticated,
    this.isDisclaimerAccepted = false,
  });
}

/// BLoC orchestrating the initial loading logic (validating tokens, caching, etc.)
class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(SplashInitial());

  Future<void> initializeApp() async {
    emit(SplashLoading());

    // Simulate minor delay for branding
    await Future.delayed(const Duration(seconds: 2));

    // Check if user is logged in and has an access token
    final isLoggedIn =
        await ServiceLocator.instance.sharedPrefs.getBool(StorageKeys.isLoggedIn);
    final token = await ServiceLocator.instance.secureStorage.getString(
        StorageKeys.accessToken);

    final isAuthenticated = isLoggedIn && token != null;
    bool isDisclaimerAccepted = false;

    if (isAuthenticated) {
      final disclaimerResult =
          await ServiceLocator.instance.getRiskDisclaimerUseCase();
      isDisclaimerAccepted = disclaimerResult.fold(
        (_) => false,
        (disclaimer) => disclaimer.accepted,
      );
    }

    emit(SplashCompleted(
      isAuthenticated: isAuthenticated,
      isDisclaimerAccepted: isDisclaimerAccepted,
    ));
  }
}
