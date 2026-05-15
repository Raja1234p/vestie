import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/failures.dart';
import '../../../project_detail/domain/entities/project_detail_entity.dart';
import '../../../project_detail/domain/repositories/project_detail_repository.dart';
import '../../../project_detail/domain/usecases/list_pending_join_requests_usecase.dart';

enum ProjectDetailTab { borrowRequests, members }

// EVENTS
abstract class ProjectDetailEvent extends Equatable {
  const ProjectDetailEvent();
  @override
  List<Object?> get props => [];
}

class LoadProjectDetailEvent extends ProjectDetailEvent {
  final String projectId;
  const LoadProjectDetailEvent({required this.projectId});
  @override
  List<Object?> get props => [projectId];
}

class ChangeTabEvent extends ProjectDetailEvent {
  final ProjectDetailTab activeTab;
  const ChangeTabEvent({required this.activeTab});
  @override
  List<Object?> get props => [activeTab];
}

// STATES
abstract class ProjectDetailState extends Equatable {
  const ProjectDetailState();
  @override
  List<Object?> get props => [];
}

class ProjectDetailInitial extends ProjectDetailState {}
class ProjectDetailLoading extends ProjectDetailState {}

class ProjectDetailLoaded extends ProjectDetailState {
  final ProjectDetailEntity project;
  final bool isLeader;
  final ProjectDetailTab activeTab;
  /// From Week 3 `GET /projects/{id}/memberships/pending` when viewer can manage.
  final int pendingJoinRequestCount;

  ProjectDetailLoaded({
    required this.project,
    this.activeTab = ProjectDetailTab.borrowRequests,
    int? pendingJoinRequestCount,
  })  : isLeader = project.isLeader,
        pendingJoinRequestCount =
            pendingJoinRequestCount ?? project.pendingJoinRequestCount;

  ProjectDetailLoaded copyWith({
    ProjectDetailEntity? project,
    ProjectDetailTab? activeTab,
    int? pendingJoinRequestCount,
  }) {
    return ProjectDetailLoaded(
      project: project ?? this.project,
      activeTab: activeTab ?? this.activeTab,
      pendingJoinRequestCount:
          pendingJoinRequestCount ?? this.pendingJoinRequestCount,
    );
  }

  @override
  List<Object?> get props =>
      [project, isLeader, activeTab, pendingJoinRequestCount];
}

class ProjectDetailError extends ProjectDetailState {
  final String message;
  const ProjectDetailError({required this.message});
  @override
  List<Object?> get props => [message];
}

// BLOC
class ProjectDetailBloc extends Bloc<ProjectDetailEvent, ProjectDetailState> {
  final ProjectDetailRepository repository;
  final ListPendingJoinRequestsUseCase? _listPendingJoinRequests;

  ProjectDetailBloc({
    required this.repository,
    ListPendingJoinRequestsUseCase? listPendingJoinRequests,
  })  : _listPendingJoinRequests = listPendingJoinRequests,
        super(ProjectDetailInitial()) {
    on<LoadProjectDetailEvent>(_onLoadProjectDetail);
    on<ChangeTabEvent>(_onChangeTab);
  }

  Future<void> _onLoadProjectDetail(
    LoadProjectDetailEvent event,
    Emitter<ProjectDetailState> emit,
  ) async {
    emit(ProjectDetailLoading());
    final result = await repository.getProjectDetail(projectId: event.projectId);

    await result.fold(
      (failure) async {
        emit(ProjectDetailError(message: _messageFor(failure)));
      },
      (project) async {
        var pendingCount = project.pendingJoinRequestCount;
        final listPending = _listPendingJoinRequests;
        if (project.hasManagementPrivileges && listPending != null) {
          final pendingResult = await listPending(event.projectId);
          pendingResult.fold(
            (_) {},
            (list) => pendingCount = list.length,
          );
        }
        emit(ProjectDetailLoaded(
          project: project,
          pendingJoinRequestCount: pendingCount,
        ));
      },
    );
  }

  static String _messageFor(Failure failure) {
    if (failure is NetworkFailure) return AppStrings.errorNetwork;
    if (failure is ForbiddenFailure) return AppStrings.errorForbidden;
    final msg = failure.message.toLowerCase();
    if (msg.contains('not found')) return AppStrings.projectNotFound;
    return failure.message;
  }

  void _onChangeTab(ChangeTabEvent event, Emitter<ProjectDetailState> emit) {
    final curr = state;
    if (curr is ProjectDetailLoaded) {
      emit(curr.copyWith(activeTab: event.activeTab));
    }
  }
}
