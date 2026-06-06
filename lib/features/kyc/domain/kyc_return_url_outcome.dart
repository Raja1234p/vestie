import 'package:vestie/features/kyc/domain/entities/kyc_status_entity.dart';

/// Outcome after Stripe redirects to the hosted onboarding `return_url`.
///
/// Stripe Account Links: `return_url` only means the user left hosted onboarding
/// (completed, saved for later, or exited). Check account requirements via API.
/// https://docs.stripe.com/connect/custom/hosted-onboarding
enum KycReturnUrlOutcome { withdrawReady, underReview, incomplete, rejected }

extension KycStatusEntityReturnUrl on KycStatusEntity {
  KycReturnUrlOutcome get returnUrlOutcome {
    if (canWithdraw) return KycReturnUrlOutcome.withdrawReady;

    if (status == KycStatus.rejected) {
      return KycReturnUrlOutcome.rejected;
    }

    if (requirementsCurrentlyDue.isNotEmpty) {
      return KycReturnUrlOutcome.incomplete;
    }

    if (status == KycStatus.pending) {
      return KycReturnUrlOutcome.underReview;
    }

    if (status == KycStatus.verified) {
      return KycReturnUrlOutcome.withdrawReady;
    }

    return KycReturnUrlOutcome.incomplete;
  }
}
