/// One-shot flags set before [context.go] to `/dashboard` so tabs can refetch
/// after flows where the route stack is replaced (e.g. create project success).
class PendingDashboardRefresh {
  PendingDashboardRefresh._();

  static bool _homeProjectList = false;
  static bool _discoverProjectList = false;

  static void markHomeProjectList() => _homeProjectList = true;

  static void markDiscoverProjectList() => _discoverProjectList = true;

  /// Call once when creating [HomeBloc]; clears the flag if it was set.
  static bool consumeHomeProjectList() {
    if (!_homeProjectList) return false;
    _homeProjectList = false;
    return true;
  }

  /// Call from [DiscoverCubit.loadIfNeeded]; clears the flag if it was set.
  static bool consumeDiscoverProjectList() {
    if (!_discoverProjectList) return false;
    _discoverProjectList = false;
    return true;
  }
}
