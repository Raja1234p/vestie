import 'package:equatable/equatable.dart';

/// Optional [GoRouterState.extra] for [AppRoutes.dashboard].
///
/// Declares one-shot shell behaviour (e.g. refetch lists after create-project).
/// [navigationMark] disambiguates repeated navigations so keyed subtrees reset.
final class DashboardShellArgs extends Equatable {
  final bool reloadHomeProjectList;
  final bool reloadDiscoverProjectList;

  /// Bottom-nav tab to show when the shell opens (0 = Home, 1 = Discover, …).
  final int initialTabIndex;

  /// After deposit/withdraw success — refetch `GET /wallet` on the wallet tab.
  final bool reloadWallet;

  /// Monotonic-ish id (e.g. `DateTime.now().microsecondsSinceEpoch`) when forcing reload.
  final int navigationMark;

  const DashboardShellArgs({
    this.reloadHomeProjectList = false,
    this.reloadDiscoverProjectList = false,
    this.initialTabIndex = 0,
    this.reloadWallet = false,
    this.navigationMark = 0,
  });

  @override
  List<Object?> get props => [
    reloadHomeProjectList,
    reloadDiscoverProjectList,
    initialTabIndex,
    reloadWallet,
    navigationMark,
  ];
}
