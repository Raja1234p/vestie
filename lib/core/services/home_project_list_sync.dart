import 'package:vestie/user/features/home/domain/entities/project.dart';

/// Keeps home project cards in sync after contribute (detail updates via bloc;
/// home list is a separate fetch and does not auto-refresh on pop).
class HomeProjectListSync {
  HomeProjectListSync._();

  static final Map<String, double> _pendingPotByProjectId = {};

  /// Set from [HomeScreen] while mounted — applies pot patches to [HomeBloc].
  static void Function(String projectId, double projectPot)? onProjectPotUpdated;

  static bool _refreshHomeOnNextDetailPop = false;

  static void recordContribution({
    required String projectId,
    required double projectPot,
  }) {
    if (projectId.isEmpty || projectPot <= 0) return;
    _pendingPotByProjectId[projectId] = projectPot;
    _refreshHomeOnNextDetailPop = true;
    onProjectPotUpdated?.call(projectId, projectPot);
  }

  /// When true, popping project detail should reload the home list (shell `go`).
  static bool consumeRefreshHomeOnPop() {
    if (!_refreshHomeOnNextDetailPop) return false;
    _refreshHomeOnNextDetailPop = false;
    return true;
  }

  static List<Project> applyPendingPots(List<Project> projects) {
    if (_pendingPotByProjectId.isEmpty) return projects;
    return projects
        .map((p) {
          final pot = _pendingPotByProjectId[p.id];
          if (pot == null) return p;
          return p.copyWith(currentAmount: pot);
        })
        .toList(growable: false);
  }

  /// Drops a pending patch once the API list matches or exceeds it.
  static void reconcileAfterFetch(List<Project> projects) {
    for (final p in projects) {
      final pending = _pendingPotByProjectId[p.id];
      if (pending == null) continue;
      final apiAmount = p.currentAmount;
      if (apiAmount != null && apiAmount >= pending - 0.01) {
        _pendingPotByProjectId.remove(p.id);
      }
    }
    if (_pendingPotByProjectId.isEmpty) {
      _refreshHomeOnNextDetailPop = false;
    }
  }
}
