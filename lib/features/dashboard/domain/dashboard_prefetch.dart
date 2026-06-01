/// Tracks data already loaded for the main shell so off-tabs do not repeat the same APIs.
class DashboardPrefetch {
  DashboardPrefetch._();

  /// Set after [HomeBloc] successfully calls `GET /users/me` for the dashboard session.
  static bool userMeLoadedOnDashboard = false;

  static bool riskDisclaimerAccepted = false;
  static bool walletLoadedOnDashboard = false;
  static DateTime? walletFetchedAt;

  static void markUserMeLoaded() {
    userMeLoadedOnDashboard = true;
  }

  static void markRiskDisclaimerAccepted() {
    riskDisclaimerAccepted = true;
  }

  static void markWalletLoaded() {
    walletLoadedOnDashboard = true;
    walletFetchedAt = DateTime.now();
  }

  static void invalidateWallet() {
    walletLoadedOnDashboard = false;
    walletFetchedAt = null;
  }

  static void reset() {
    userMeLoadedOnDashboard = false;
    riskDisclaimerAccepted = false;
    invalidateWallet();
  }
}
