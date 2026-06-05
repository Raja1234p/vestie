import 'package:vestie/features/projects/presentation/bloc/project_detail_bloc.dart';

/// Links an active [ProjectDetailBloc] to member / moderation flows so every
/// member-screen mutation can reload project detail even across routes.
class ProjectDetailReloadCoordinator {
  ProjectDetailReloadCoordinator._();

  static final Map<String, ProjectDetailBloc> _blocsByProjectId = {};

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
    }
  }

  static Future<void> reload(String projectId) async {
    final id = projectId.trim();
    if (id.isEmpty) return;
    final bloc = _blocsByProjectId[id];
    if (bloc == null) return;
    await bloc.reloadDetailAndWait(id);
  }
}
