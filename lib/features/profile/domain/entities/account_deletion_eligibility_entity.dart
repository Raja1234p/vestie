/// Result of `GET /account/deletion-eligibility` (`eligible`, `reasons[]`).
class AccountDeletionEligibilityEntity {
  final bool isEligible;

  /// Backend-supplied messages when [isEligible] is false.
  final List<String> reasons;

  const AccountDeletionEligibilityEntity({
    required this.isEligible,
    this.reasons = const [],
  });

  String get displayIneligibilityMessage =>
      reasons.map((r) => r.trim()).where((r) => r.isNotEmpty).join('\n');
}
