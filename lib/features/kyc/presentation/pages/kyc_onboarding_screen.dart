import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/utils/logger.dart';
import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/core/widgets/common/stripe_browser_onboarding_screen.dart';
import 'package:vestie/features/kyc/domain/kyc_return_url_outcome.dart';
import 'package:vestie/features/kyc/domain/kyc_status_cache.dart';
import 'package:vestie/features/kyc/presentation/constants/kyc_flow_constants.dart';
import 'package:vestie/features/kyc/presentation/mappers/kyc_onboarding_result_mapper.dart';
import 'package:vestie/features/kyc/presentation/models/kyc_onboarding_result.dart';

/// Stripe Connect Express onboarding in the system browser (`POST /kyc/start`).
class KycOnboardingScreen extends StatelessWidget {
  const KycOnboardingScreen({super.key});

  Future<void> _checkStatusAndPop(
    BuildContext context, {
    required bool finalizeOnIncomplete,
  }) async {
    KycStatusCache.clear();
    final result = await ServiceLocator.instance.getKycStatusUseCase(
      forceRefresh: true,
    );
    if (!context.mounted) return;
    final outcome = result.fold(
      (_) => KycOnboardingResult.incomplete,
      (status) =>
          KycOnboardingResultMapper.fromReturnUrlOutcome(status.returnUrlOutcome),
    );
    if (!finalizeOnIncomplete &&
        (outcome == KycOnboardingResult.incomplete ||
            outcome == KycOnboardingResult.canceled)) {
      return;
    }
    if (!context.mounted) return;
    context.pop(outcome);
  }

  bool _shouldAutoClose(KycOnboardingResult outcome) =>
      outcome == KycOnboardingResult.completed ||
      outcome == KycOnboardingResult.pendingReview ||
      outcome == KycOnboardingResult.rejected;

  Future<void> _checkStatusMaybePop(BuildContext context) async {
    KycStatusCache.clear();
    final result = await ServiceLocator.instance.getKycStatusUseCase(
      forceRefresh: true,
    );
    if (!context.mounted) return;
    final outcome = result.fold(
      (_) => KycOnboardingResult.incomplete,
      (status) =>
          KycOnboardingResultMapper.fromReturnUrlOutcome(status.returnUrlOutcome),
    );
    if (_shouldAutoClose(outcome) && context.mounted) {
      context.pop(outcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StripeBrowserOnboardingScreen(
      title: AppStrings.kycOnboardingTitle,
      urlMissingMessage: AppStrings.kycOnboardingUrlMissing,
      bodyMessage: AppStrings.stripeBrowserOnboardingKycBody,
      resolveOnboardingUrl: () async {
        final refreshUrl = KycFlowConstants.refreshUrl;
        final returnUrl = KycFlowConstants.returnUrl;
        AppLogger.info(
          'POST /kyc/start — refreshUrl=$refreshUrl returnUrl=$returnUrl '
          '(Stripe "Return to …" uses refreshUrl)',
          name: 'StripeOnboarding',
        );
        final result = await ServiceLocator.instance.startKycUseCase(
          country: 'US',
          refreshUrl: refreshUrl,
          returnUrl: returnUrl,
        );
        return result.fold(
          (failure) => throw Exception(FailureMapper.userMessage(failure)),
          (start) {
            AppLogger.debug(
              'kyc/start status=${start.status} expires=${start.onboardingExpiresAt}',
              name: 'StripeOnboarding',
            );
            return start.onboardingUrl;
          },
        );
      },
      isReturnUrl: KycFlowConstants.isCompletionUrl,
      isRefreshUrl: KycFlowConstants.isRefreshUrl,
      onReturnUrl: () => _checkStatusAndPop(context, finalizeOnIncomplete: true),
      onManualCheck: ({bool silent = false}) => silent
          ? _checkStatusMaybePop(context)
          : _checkStatusAndPop(context, finalizeOnIncomplete: true),
      onCancel: () {
        if (context.mounted) {
          context.pop(KycOnboardingResult.canceled);
        }
      },
    );
  }
}
