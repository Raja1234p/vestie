/// Distribution processing phase for approved investment closure (leader Figma).
enum SuccessVoteOutcomeDistributionPhase {
  none,
  inProgress,
  complete;

  bool get isDistribution =>
      this != SuccessVoteOutcomeDistributionPhase.none;
}

/// Parses API `distributionStatus` or `displayStatus` for leader distribution UI.
SuccessVoteOutcomeDistributionPhase distributionPhaseFromStatusLabel(
  String? raw,
) {
  final normalized = (raw ?? '').trim().toLowerCase();
  if (normalized.isEmpty) {
    return SuccessVoteOutcomeDistributionPhase.none;
  }

  final mentionsDistribution = normalized.contains('distribution') ||
      normalized.contains('distributing') ||
      normalized.contains('distributions');
  if (!mentionsDistribution) {
    return SuccessVoteOutcomeDistributionPhase.none;
  }

  if (normalized.contains('complete') ||
      normalized.contains('completed') ||
      normalized.contains('distributed')) {
    return SuccessVoteOutcomeDistributionPhase.complete;
  }
  if (normalized.contains('progress') ||
      normalized.contains('processing') ||
      normalized.contains('pending') ||
      normalized.contains('calculating')) {
    return SuccessVoteOutcomeDistributionPhase.inProgress;
  }

  return SuccessVoteOutcomeDistributionPhase.inProgress;
}

/// Wire enum from `GET /projects/{id}` → `voting.distributionStatus`.
SuccessVoteOutcomeDistributionPhase distributionPhaseFromApiValue(String? raw) {
  final normalized = (raw ?? '').trim().toLowerCase();
  return switch (normalized) {
    'inprogress' ||
    'in_progress' ||
    'progress' ||
    'pending' =>
      SuccessVoteOutcomeDistributionPhase.inProgress,
    'complete' || 'completed' => SuccessVoteOutcomeDistributionPhase.complete,
    'none' || '' => SuccessVoteOutcomeDistributionPhase.none,
    _ => distributionPhaseFromStatusLabel(raw),
  };
}
