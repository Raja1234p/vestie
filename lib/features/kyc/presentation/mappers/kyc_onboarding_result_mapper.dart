import 'package:vestie/features/kyc/domain/kyc_return_url_outcome.dart';
import 'package:vestie/features/kyc/presentation/models/kyc_onboarding_result.dart';

/// Maps domain Stripe return outcomes to route pop values + toasts.
class KycOnboardingResultMapper {
  KycOnboardingResultMapper._();

  static KycOnboardingResult fromReturnUrlOutcome(KycReturnUrlOutcome outcome) {
    return switch (outcome) {
      KycReturnUrlOutcome.withdrawReady => KycOnboardingResult.completed,
      KycReturnUrlOutcome.underReview => KycOnboardingResult.pendingReview,
      KycReturnUrlOutcome.incomplete => KycOnboardingResult.incomplete,
      KycReturnUrlOutcome.rejected => KycOnboardingResult.rejected,
    };
  }
}
