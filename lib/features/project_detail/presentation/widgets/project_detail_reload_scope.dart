import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vestie/features/project_detail/presentation/project_detail_reload_coordinator.dart';
import 'package:vestie/features/projects/presentation/bloc/project_detail_bloc.dart';

/// Registers the active [ProjectDetailBloc] for [projectId] while this subtree
/// is mounted.
class ProjectDetailReloadScope extends StatefulWidget {
  final String projectId;
  final Widget child;

  const ProjectDetailReloadScope({
    super.key,
    required this.projectId,
    required this.child,
  });

  @override
  State<ProjectDetailReloadScope> createState() =>
      _ProjectDetailReloadScopeState();
}

class _ProjectDetailReloadScopeState extends State<ProjectDetailReloadScope> {
  ProjectDetailBloc? _bloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bloc = context.read<ProjectDetailBloc>();
    if (identical(_bloc, bloc)) return;
    if (_bloc != null) {
      ProjectDetailReloadCoordinator.unregister(widget.projectId, _bloc!);
    }
    _bloc = bloc;
    ProjectDetailReloadCoordinator.register(widget.projectId, bloc);
  }

  @override
  void dispose() {
    final bloc = _bloc;
    if (bloc != null) {
      ProjectDetailReloadCoordinator.unregister(widget.projectId, bloc);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
