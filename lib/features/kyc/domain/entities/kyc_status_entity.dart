import 'package:equatable/equatable.dart';

enum KycStatus { notStarted, pending, verified, rejected }

KycStatus kycStatusFromApi(String raw) {
  switch (raw.toLowerCase()) {
    case 'verified':
      return KycStatus.verified;
    case 'pending':
      return KycStatus.pending;
    case 'rejected':
      return KycStatus.rejected;
    default:
      return KycStatus.notStarted;
  }
}

class KycStatusEntity extends Equatable {
  final KycStatus status;
  final String? stripeConnectAccountId;
  final bool chargesEnabled;
  final bool payoutsEnabled;
  final List<String> requirementsCurrentlyDue;

  const KycStatusEntity({
    required this.status,
    this.stripeConnectAccountId,
    this.chargesEnabled = false,
    this.payoutsEnabled = false,
    this.requirementsCurrentlyDue = const [],
  });

  bool get canWithdraw => status == KycStatus.verified && payoutsEnabled;

  @override
  List<Object?> get props => [
    status,
    stripeConnectAccountId,
    chargesEnabled,
    payoutsEnabled,
    requirementsCurrentlyDue,
  ];
}

class KycStartResultEntity extends Equatable {
  final KycStatus status;
  final String? onboardingUrl;
  final DateTime? onboardingExpiresAt;

  const KycStartResultEntity({
    required this.status,
    this.onboardingUrl,
    this.onboardingExpiresAt,
  });

  @override
  List<Object?> get props => [status, onboardingUrl, onboardingExpiresAt];
}
