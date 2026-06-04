/// Args for [AppRoutes.projectJoinedSuccess] ([ProjectJoinedSuccessScreen]).
class ProjectJoinedSuccessRouteArgs {
  final ProjectJoinSuccessKind kind;
  final String projectId;
  final String projectName;
  final bool isInvestment;

  /// Invite-link success — clear staged invite when leaving the screen.
  final bool fromInviteLink;

  const ProjectJoinedSuccessRouteArgs({
    required this.projectId,
    required this.projectName,
    this.isInvestment = false,
    this.kind = ProjectJoinSuccessKind.immediate,
    this.fromInviteLink = false,
  });
}

enum ProjectJoinSuccessKind {
  /// Public / immediate join (`status: active`) — Open Project → detail.
  immediate,

  /// Private / pending approval — Done → dashboard.
  requestPending,
}
