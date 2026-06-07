import 'package:vestie/core/constants/app_strings.dart';
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

  /// `POST /bank-accounts` → Custom Tab → `vestie://kyc/*` → sync accounts on screen.
  static Future<BankLinkOnboardingResult> run() async {
    while (true) {
      final linkResult = await _link();
      if (linkResult.hasLinkedAccount) {
        return BankLinkOnboardingResult.linked;
      }

      final trimmed = linkResult.onboardingUrl?.trim() ?? '';
      if (trimmed.isEmpty) {
        throw Exception(AppStrings.bankLinkOnboardingUrlMissing);
      }

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
        AppLogger.info('Bank return redirect', name: _logTag);
        return BankLinkOnboardingResult.completed;
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

}
