/// Loads `GET /projects/{id}` then opens [SuccessVoteOutcomeScreen] with API tallies.
class SuccessVoteOutcomeLoadRouteArgs {
  final String projectId;
  final String? initialProjectName;

  const SuccessVoteOutcomeLoadRouteArgs({
    required this.projectId,
    this.initialProjectName,
  });
}
