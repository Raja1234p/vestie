/// Navigation extras for `/project/detail` and `/project/investment-detail`.
///
/// After load, UI follows API `project.viewerRole`:
/// `GroupLeader` | `CoLeader` (same moderator UI for now) | `Member`.
///
/// **Where [initialProjectName] is set**
/// | Entry | Source |
/// |-------|--------|
/// | Home / Discover card | [Project.name] via [openProjectFromCard] |
/// | Create success → Go to my Project | API [CreatedProjectEntity.name], form fallback |
/// | Deep link by id only | null → shimmer without title until GET returns |
/// | Invite preview → detail (if used) | [InvitePreviewEntity.projectName] |
class ProjectDetailRouteArgs {
  final String projectId;

  /// Shown in [PostAuthHeader] while `GET /projects/{id}` loads.
  final String? initialProjectName;

  /// When true, back/leave navigates to dashboard and reloads home/discover lists
  /// (e.g. after create-project).
  final bool refreshHomeOnPop;

  /// When true, back/leave navigates to Discover and reloads the discover list only.
  final bool refreshDiscoverOnPop;

  /// Profile completed list only — set by [openCompletedProjectDetail].
  /// When true, detail shows read-only shell instead of outcome takeover.
  final bool skipCompletedOutcomeTakeover;

  const ProjectDetailRouteArgs({
    required this.projectId,
    this.initialProjectName,
    this.refreshHomeOnPop = false,
    this.refreshDiscoverOnPop = false,
    this.skipCompletedOutcomeTakeover = false,
  });

  /// Prefer non-empty [initialProjectName]; otherwise null (no placeholder title).
  static String? normalizedName(String? name) {
    final trimmed = name?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }
}
