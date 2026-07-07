/// Refund processing phase for rejected closure-vote outcomes (Figma).
enum SuccessVoteOutcomeRefundPhase {
  none,
  inProgress,
  complete;

  bool get isRefund => this != SuccessVoteOutcomeRefundPhase.none;
}

SuccessVoteOutcomeRefundPhase refundPhaseFromDisplayStatus(String? raw) {
  final normalized = (raw ?? '').trim().toLowerCase();
  if (normalized.isEmpty) return SuccessVoteOutcomeRefundPhase.none;
  if (!normalized.contains('refund')) {
    return SuccessVoteOutcomeRefundPhase.none;
  }
  if (normalized.contains('complete') ||
      normalized.contains('completed') ||
      normalized.contains('returned')) {
    return SuccessVoteOutcomeRefundPhase.complete;
  }
  if (normalized.contains('progress') ||
      normalized.contains('processing') ||
      normalized.contains('pending')) {
    return SuccessVoteOutcomeRefundPhase.inProgress;
  }
  return SuccessVoteOutcomeRefundPhase.inProgress;
}
