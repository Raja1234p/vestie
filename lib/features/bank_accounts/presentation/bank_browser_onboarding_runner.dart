import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/services/bank_accounts_prefetch.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/core/stripe/stripe_hosted_onboarding_launcher.dart';
import 'package:vestie/core/utils/logger.dart';
import 'package:vestie/features/bank_accounts/domain/entities/bank_link_result_entity.dart';
import 'package:vestie/features/bank_accounts/presentation/constants/bank_flow_constants.dart';
import 'package:vestie/features/bank_accounts/presentation/models/bank_link_onboarding_result.dart';

/// Stripe bank linking in the system browser — no intermediate onboarding screen.
class BankBrowserOnboardingRunner {
  BankBrowserOnboardingRunner._();

  static const _logTag = 'StripeOnboarding';

  /// `POST /bank-accounts` → Custom Tab → `vestie://bank/*` → `GET /bank-accounts`.
  ///
  /// [onBrowserPresented] fires immediately before the Custom Tab opens (hide button loader).
  static Future<BankLinkOnboardingResult> run({
    void Function()? onBrowserPresented,
  }) async {
    while (true) {
      final linkResult = await _link();
      if (linkResult.hasLinkedAccount) {
        return BankLinkOnboardingResult.linked;
      }

      final trimmed = linkResult.onboardingUrl?.trim() ?? '';
      if (trimmed.isEmpty) {
        throw Exception(AppStrings.bankLinkOnboardingUrlMissing);
      }

      onBrowserPresented?.call();
      final callback = await StripeHostedOnboardingLauncher.openAndWaitForRedirect(
        trimmed,
        httpsCompletionPath: BankFlowConstants.httpsCompletionPath,
      );
      if (callback == null) {
        AppLogger.info('Bank browser closed without redirect', name: _logTag);
        return BankLinkOnboardingResult.canceled;
      }
      if (BankFlowConstants.isRefreshUrl(callback)) {
        AppLogger.info('Bank refresh redirect — new session', name: _logTag);
        continue;
      }
      if (BankFlowConstants.isCompletionUrl(callback)) {
        AppLogger.info(
          'Bank return redirect — syncing accounts',
          name: _logTag,
        );
        return _outcomeAfterReturn();
      }
      AppLogger.error('Unknown bank redirect: $callback', name: _logTag);
      return BankLinkOnboardingResult.incomplete;
    }
  }

  static Future<BankLinkResultEntity> _link() async {
    final result = await ServiceLocator.instance.linkBankAccountUseCase(
      refreshUrl: BankFlowConstants.refreshUrl,
      returnUrl: BankFlowConstants.returnUrl,
    );
    return result.fold(
      (failure) => throw Exception(FailureMapper.userMessage(failure)),
      (link) => link,
    );
  }

  static Future<BankLinkOnboardingResult> _outcomeAfterReturn() async {
    await BankAccountsPrefetch.refresh();
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
}
