class SuccessVoteOutcomeLoadRouteArgs {
  final String projectId;
  final String? initialProjectName;

  /// Profile → Completed Projects list only — outcome CTA is View Details.
  final bool fromCompletedProjectsList;

  const SuccessVoteOutcomeLoadRouteArgs({
    required this.projectId,
    this.initialProjectName,
    this.fromCompletedProjectsList = false,
  });
}
