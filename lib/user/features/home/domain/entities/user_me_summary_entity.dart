/// `GET /users/me/summary` — home header and dashboard stats.
class UserMeSummaryEntity {
  final double totalContributed;
  final int activeProjectsCount;
  final int completedProjectsCount;
  final int joinedProjectsCount;

  const UserMeSummaryEntity({
    this.totalContributed = 0,
    this.activeProjectsCount = 0,
    this.completedProjectsCount = 0,
    this.joinedProjectsCount = 0,
  });
}
