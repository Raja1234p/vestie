import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/core/widgets/common/stripe_browser_onboarding_screen.dart';
import 'package:vestie/features/bank_accounts/domain/bank_accounts_cache.dart';
import 'package:vestie/features/bank_accounts/presentation/constants/bank_flow_constants.dart';
import 'package:vestie/features/bank_accounts/presentation/models/bank_link_onboarding_result.dart';

/// Stripe bank onboarding via browser (`POST /bank-accounts` → `onboardingUrl`).
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

  Future<BankLinkOnboardingResult> _loadOutcome() async {
    BankAccountsCache.clear();
    final result = await ServiceLocator.instance.listBankAccountsUseCase(
      forceRefresh: true,
    );
    return result.fold(
      (_) => BankLinkOnboardingResult.incomplete,
      (accounts) => accounts.isNotEmpty
          ? BankLinkOnboardingResult.linked
          : BankLinkOnboardingResult.incomplete,
    );
  }

  Future<void> _finalize(BuildContext context) async {
    final outcome = await _loadOutcome();
    if (!context.mounted) return;
    context.pop(outcome);
  }

  Future<void> _checkMaybePop(BuildContext context) async {
    final outcome = await _loadOutcome();
    if (outcome == BankLinkOnboardingResult.linked && context.mounted) {
      context.pop(outcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StripeBrowserOnboardingScreen(
      title: AppStrings.bankLinkOnboardingTitle,
      urlMissingMessage: AppStrings.bankLinkOnboardingUrlMissing,
      bodyMessage: AppStrings.stripeBrowserOnboardingBankBody,
      resolveOnboardingUrl: _resolveOnboardingUrl,
      onImmediateSuccess: () {
        BankAccountsCache.clear();
        if (context.mounted) {
          context.pop(BankLinkOnboardingResult.linked);
        }
      },
      isReturnUrl: BankFlowConstants.isCompletionUrl,
      isRefreshUrl: BankFlowConstants.isRefreshUrl,
      onReturnUrl: () => _finalize(context),
      onManualCheck: ({bool silent = false}) =>
          silent ? _checkMaybePop(context) : _finalize(context),
      onCancel: () {
        if (context.mounted) {
          context.pop(BankLinkOnboardingResult.canceled);
        }
      },
    );
  }
}
