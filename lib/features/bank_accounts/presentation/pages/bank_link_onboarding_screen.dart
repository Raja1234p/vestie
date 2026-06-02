import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/core/widgets/common/stripe_onboarding_flow_shell.dart';
import 'package:vestie/features/bank_accounts/domain/bank_accounts_cache.dart';
import 'package:vestie/features/bank_accounts/presentation/constants/bank_flow_constants.dart';

/// Stripe bank onboarding via `POST /bank-accounts` → `onboardingUrl` WebView.
class BankLinkOnboardingScreen extends StatelessWidget {
  const BankLinkOnboardingScreen({super.key});

  static Future<String?> _resolveOnboardingUrl() async {
    final result = await ServiceLocator.instance.linkBankAccountUseCase(
      refreshUrl: BankFlowConstants.refreshUrl,
      returnUrl: BankFlowConstants.returnUrl,
    );
    return result.fold(
      (failure) => throw Exception(FailureMapper.userMessage(failure)),
      (linkResult) {
        if (linkResult.hasLinkedAccount) {
          return null;
        }
        return linkResult.onboardingUrl ?? '';
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StripeOnboardingFlowShell(
      title: AppStrings.bankLinkOnboardingTitle,
      urlMissingMessage: AppStrings.bankLinkOnboardingUrlMissing,
      resolveOnboardingUrl: _resolveOnboardingUrl,
      onImmediateSuccess: () {
        BankAccountsCache.clear();
        if (context.mounted) {
          context.pop(true);
        }
      },
      isCompletionUrl: BankFlowConstants.isCompletionUrl,
      isRefreshUrl: BankFlowConstants.isRefreshUrl,
      onFlowComplete: () {
        BankAccountsCache.clear();
        if (context.mounted) {
          context.pop(true);
        }
      },
      onCancel: () {
        if (context.mounted) {
          context.pop(false);
        }
      },
    );
  }
}
