/// Navigation extras for profile → completed project read-only detail.
class CompletedProjectDetailRouteArgs {
  const CompletedProjectDetailRouteArgs({
    required this.projectId,
    this.initialProjectName,
  });

  final String projectId;
  final String? initialProjectName;
}
