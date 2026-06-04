/// Args for [AppRoutes.projectJoinedSuccess] ([ProjectJoinedSuccessScreen]).
class ProjectJoinedSuccessRouteArgs {
  final String projectId;
  final String projectName;
  final bool isInvestment;

  const ProjectJoinedSuccessRouteArgs({
    required this.projectId,
    required this.projectName,
    this.isInvestment = false,
  });
}
