import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vestie/core/realtime/project_realtime_event.dart';
import 'package:vestie/core/services/wallet_prefetch.dart';
import 'package:vestie/core/realtime/projects_signalr_service.dart';
import 'package:vestie/features/projects/presentation/bloc/project_detail_bloc.dart';
import 'package:vestie/features/wallet/presentation/cubit/wallet_cubit.dart';

/// Joins SignalR project channel while visible; refreshes pot (+ wallet on contribute).
class ProjectRealtimeScope extends StatefulWidget {
  const ProjectRealtimeScope({
    super.key,
    required this.projectId,
    required this.child,
  });

  final String projectId;
  final Widget child;

  @override
  State<ProjectRealtimeScope> createState() => _ProjectRealtimeScopeState();
}

class _ProjectRealtimeScopeState extends State<ProjectRealtimeScope> {
  StreamSubscription<ProjectRealtimeEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    unawaited(WalletPrefetch.warmIfNeeded());
    ProjectsSignalRService.instance.joinProject(widget.projectId);
    _subscription = ProjectsSignalRService.instance.events.listen(_onEvent);
  }

  @override
  void didUpdateWidget(ProjectRealtimeScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.projectId != widget.projectId) {
      ProjectsSignalRService.instance.leaveProject(oldWidget.projectId);
      ProjectsSignalRService.instance.joinProject(widget.projectId);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    ProjectsSignalRService.instance.leaveProject(widget.projectId);
    super.dispose();
  }

  void _onEvent(ProjectRealtimeEvent event) {
    if (event.projectId != widget.projectId) return;
    if (!mounted) return;

    final bloc = context.read<ProjectDetailBloc>();
    bloc.add(RefreshProjectPotEvent(projectId: widget.projectId));

    if (event.kind == ProjectRealtimeEventKind.contributionMade) {
      unawaited(WalletPrefetch.refresh());
      try {
        context.read<WalletCubit>().load(forceRefresh: true);
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
