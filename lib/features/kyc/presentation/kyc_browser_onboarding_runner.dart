import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/core/stripe/stripe_hosted_onboarding_launcher.dart';
import 'package:vestie/core/utils/logger.dart';
import 'package:vestie/features/kyc/domain/kyc_return_url_outcome.dart';
import 'package:vestie/features/kyc/domain/kyc_status_cache.dart';
import 'package:vestie/features/kyc/presentation/constants/kyc_flow_constants.dart';
import 'package:vestie/features/kyc/presentation/mappers/kyc_onboarding_result_mapper.dart';
import 'package:vestie/features/kyc/presentation/models/kyc_onboarding_result.dart';

/// Stripe KYC in the system browser — no intermediate onboarding screen.
class KycBrowserOnboardingRunner {
  KycBrowserOnboardingRunner._();

  static const _logTag = 'StripeOnboarding';

  /// `POST /kyc/start` → Custom Tab → `vestie://kyc/*` → `GET /kyc/status`.
  static Future<KycOnboardingResult> run() async {
    while (true) {
      final url = await _fetchOnboardingUrl();
      final trimmed = url?.trim() ?? '';
      if (trimmed.isEmpty) {
        throw Exception(AppStrings.kycOnboardingUrlMissing);
      }

      final callback =
          await StripeHostedOnboardingLauncher.openAndWaitForRedirect(trimmed);
      if (callback == null) {
        AppLogger.info('KYC browser closed without redirect', name: _logTag);
        return KycOnboardingResult.canceled;
      }
      if (KycFlowConstants.isRefreshUrl(callback)) {
        AppLogger.info('KYC refresh redirect — new session', name: _logTag);
        continue;
      }
      if (KycFlowConstants.isCompletionUrl(callback)) {
        AppLogger.info('KYC complete redirect — checking status', name: _logTag);
        return _resultFromStatus();
      }
      AppLogger.error('Unknown KYC redirect: $callback', name: _logTag);
      return KycOnboardingResult.incomplete;
    }
  }

  static Future<String?> _fetchOnboardingUrl() async {
    final result = await ServiceLocator.instance.startKycUseCase(
      country: 'US',
      refreshUrl: KycFlowConstants.refreshUrl,
      returnUrl: KycFlowConstants.returnUrl,
    );
    return result.fold(
      (failure) => throw Exception(FailureMapper.userMessage(failure)),
      (start) => start.onboardingUrl,
    );
  }

  static Future<KycOnboardingResult> _resultFromStatus() async {
    KycStatusCache.clear();
    final result = await ServiceLocator.instance.getKycStatusUseCase(
      forceRefresh: true,
    );
    return result.fold(
      (_) => KycOnboardingResult.incomplete,
      (status) => KycOnboardingResultMapper.fromReturnUrlOutcome(
        status.returnUrlOutcome,
      ),
    );
  }
}
