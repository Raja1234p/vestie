import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/projects/presentation/bloc/project_detail_bloc.dart';

/// Links an active [ProjectDetailBloc] to member / moderation flows so every
/// member-screen mutation can reload project detail even across routes.
class ProjectDetailReloadCoordinator {
  ProjectDetailReloadCoordinator._();

  static final Map<String, ProjectDetailBloc> _blocsByProjectId = {};
  static final Map<String, ProjectDetailEntity> _lastProjectById = {};

  static void register(String projectId, ProjectDetailBloc bloc) {
    final id = projectId.trim();
    if (id.isEmpty) return;
    _blocsByProjectId[id] = bloc;
  }

  static void unregister(String projectId, ProjectDetailBloc bloc) {
    final id = projectId.trim();
    if (id.isEmpty) return;
    final current = _blocsByProjectId[id];
    if (identical(current, bloc)) {
      _blocsByProjectId.remove(id);
      _lastProjectById.remove(id);
    }
  }

  /// Latest project detail synced via [reload] — used by routes without bloc access.
  static ProjectDetailEntity? cachedProject(String projectId) {
    final id = projectId.trim();
    if (id.isEmpty) return null;
    return _lastProjectById[id];
  }

  static Future<void> reload(String projectId) async {
    final id = projectId.trim();
    if (id.isEmpty) return;
    final bloc = _blocsByProjectId[id];
    if (bloc == null) return;
    await bloc.reloadDetailAndWait(id);
    final state = bloc.state;
    if (state is ProjectDetailLoaded) {
      _lastProjectById[id] = state.project;
    }
  }

  /// Optimistic pot merge + full `GET /projects/{id}` after contribute POST.
  static Future<void> reloadAfterContribution({
    required String projectId,
    required double projectPot,
    required List<String> vffMemberUserIds,
  }) async {
    final id = projectId.trim();
    if (id.isEmpty) return;
    final bloc = _blocsByProjectId[id];
    if (bloc == null) return;

    bloc.add(
      ApplyContributionSubmitResultEvent(
        projectId: id,
        projectPot: projectPot,
        vffMemberUserIds: vffMemberUserIds,
      ),
    );
    await bloc.reloadDetailAndWait(id);
    final state = bloc.state;
    if (state is ProjectDetailLoaded) {
      _lastProjectById[id] = state.project;
    }
  }
}
