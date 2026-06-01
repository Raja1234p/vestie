import 'package:equatable/equatable.dart';

import 'bank_account_entity.dart';

/// Result of `POST /bank-accounts` — immediate link or Stripe onboarding URL.
class BankLinkResultEntity extends Equatable {
  final BankAccountEntity? bankAccount;
  final String? onboardingUrl;
  final DateTime? onboardingExpiresAt;

  const BankLinkResultEntity({
    this.bankAccount,
    this.onboardingUrl,
    this.onboardingExpiresAt,
  });

  bool get hasLinkedAccount => bankAccount != null;

  bool get requiresOnboarding {
    final url = onboardingUrl?.trim() ?? '';
    return url.isNotEmpty && bankAccount == null;
  }

  @override
  List<Object?> get props => [bankAccount, onboardingUrl, onboardingExpiresAt];
}
