import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/auth/app_auth_session.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/storage/onboarding_prefs.dart';

/// Splash State Definitions
abstract class SplashState {}

class SplashInitial extends SplashState {}

class SplashLoading extends SplashState {}

class SplashCompleted extends SplashState {
  final bool isAuthenticated;
  final bool isDisclaimerAccepted;
  final bool hasSeenOnboarding;

  SplashCompleted({
    required this.isAuthenticated,
    this.isDisclaimerAccepted = false,
    this.hasSeenOnboarding = false,
  });
}

/// BLoC orchestrating the initial loading logic (validating tokens, caching, etc.)
class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(SplashInitial());

  static const Duration minDisplayDuration = Duration(seconds: 3);

  Future<void> initializeApp() async {
    emit(SplashLoading());

    final bootstrap = await Future.wait([
      _loadBootstrap(),
      Future<void>.delayed(minDisplayDuration),
    ]).then((results) => results.first as _SplashBootstrap);

    emit(
      SplashCompleted(
        isAuthenticated: bootstrap.isAuthenticated,
        isDisclaimerAccepted: bootstrap.isDisclaimerAccepted,
        hasSeenOnboarding: bootstrap.hasSeenOnboarding,
      ),
    );
  }

  Future<_SplashBootstrap> _loadBootstrap() async {
    await AppAuthSession.instance.syncFromStorage();
    final isAuthenticated = AppAuthSession.instance.isAuthenticated;
    var isDisclaimerAccepted = false;

    if (isAuthenticated) {
      final disclaimerResult = await ServiceLocator.instance
          .getRiskDisclaimerUseCase();
      isDisclaimerAccepted = disclaimerResult.fold(
        (_) => false,
        (disclaimer) => disclaimer.accepted,
      );
    }

    final hasSeenOnboarding = await OnboardingPrefs.hasCompleted();

    return _SplashBootstrap(
      isAuthenticated: isAuthenticated,
      isDisclaimerAccepted: isDisclaimerAccepted,
      hasSeenOnboarding: hasSeenOnboarding,
    );
  }
}

class _SplashBootstrap {
  final bool isAuthenticated;
  final bool isDisclaimerAccepted;
  final bool hasSeenOnboarding;

  const _SplashBootstrap({
    required this.isAuthenticated,
    required this.isDisclaimerAccepted,
    required this.hasSeenOnboarding,
  });
}
