import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/core/widgets/common/stripe_onboarding_flow_shell.dart';
import 'package:vestie/features/kyc/domain/entities/kyc_status_entity.dart';
import 'package:vestie/features/kyc/domain/kyc_status_cache.dart';
import 'package:vestie/features/kyc/presentation/constants/kyc_flow_constants.dart';
import 'package:vestie/features/kyc/presentation/models/kyc_onboarding_result.dart';

/// Stripe Connect Express onboarding in an in-app WebView (`POST /kyc/start`).
class KycOnboardingScreen extends StatelessWidget {
  const KycOnboardingScreen({super.key});

  static KycOnboardingResult _resultFromStatus(KycStatusEntity status) {
    if (status.canWithdraw) return KycOnboardingResult.completed;
    if (status.status == KycStatus.pending) {
      return KycOnboardingResult.pending;
    }
    return KycOnboardingResult.canceled;
  }

  Future<void> _onReturnUrlReached(BuildContext context) async {
    KycStatusCache.clear();
    final result = await ServiceLocator.instance.getKycStatusUseCase(
      forceRefresh: true,
    );
    if (!context.mounted) return;
    final outcome = result.fold(
      (_) => KycOnboardingResult.canceled,
      _resultFromStatus,
    );
    context.pop(outcome);
  }

  @override
  Widget build(BuildContext context) {
    return StripeOnboardingFlowShell(
      title: AppStrings.kycOnboardingTitle,
      urlMissingMessage: AppStrings.kycOnboardingUrlMissing,
      resolveOnboardingUrl: () async {
        final result = await ServiceLocator.instance.startKycUseCase(
          country: 'US',
          refreshUrl: KycFlowConstants.refreshUrl,
          returnUrl: KycFlowConstants.returnUrl,
        );
        return result.fold(
          (failure) => throw Exception(FailureMapper.userMessage(failure)),
          (start) => start.onboardingUrl,
        );
      },
      isCompletionUrl: KycFlowConstants.isCompletionUrl,
      isRefreshUrl: KycFlowConstants.isRefreshUrl,
      onReturnUrlReached: () => _onReturnUrlReached(context),
      onCancel: () {
        if (context.mounted) {
          context.pop(KycOnboardingResult.canceled);
        }
      },
    );
  }
}
