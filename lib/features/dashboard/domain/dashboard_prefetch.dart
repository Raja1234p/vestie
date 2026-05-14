/// Tracks data already loaded for the main shell so off-tabs do not repeat the same APIs.
class DashboardPrefetch {
  DashboardPrefetch._();

  /// Set after [HomeBloc] successfully calls `GET /users/me` for the dashboard session.
  static bool userMeLoadedOnDashboard = false;

  static void markUserMeLoaded() {
    userMeLoadedOnDashboard = true;
  }

  static void reset() {
    userMeLoadedOnDashboard = false;
  }
}
