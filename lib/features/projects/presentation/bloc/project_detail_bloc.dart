import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../project_detail/domain/entities/project_detail_entity.dart';
import '../../../project_detail/domain/repositories/project_detail_repository.dart';

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

  ProjectDetailLoaded({
    required this.project,
    this.activeTab = ProjectDetailTab.borrowRequests,
  }) : isLeader = project.isLeader;

  ProjectDetailLoaded copyWith({
    ProjectDetailEntity? project,
    ProjectDetailTab? activeTab,
  }) {
    return ProjectDetailLoaded(
      project: project ?? this.project,
      activeTab: activeTab ?? this.activeTab,
    );
  }

  @override
  List<Object?> get props => [project, isLeader, activeTab];
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

  ProjectDetailBloc({required this.repository}) : super(ProjectDetailInitial()) {
    on<LoadProjectDetailEvent>(_onLoadProjectDetail);
    on<ChangeTabEvent>(_onChangeTab);
  }

  Future<void> _onLoadProjectDetail(LoadProjectDetailEvent event, Emitter<ProjectDetailState> emit) async {
    emit(ProjectDetailLoading());
    final result = await repository.getProjectDetail(projectId: event.projectId);
    result.fold(
      (failure) => emit(ProjectDetailError(message: failure.message)),
      (project) => emit(ProjectDetailLoaded(project: project)),
    );
  }

  void _onChangeTab(ChangeTabEvent event, Emitter<ProjectDetailState> emit) {
    final curr = state;
    if (curr is ProjectDetailLoaded) {
      emit(curr.copyWith(activeTab: event.activeTab));
    }
  }
}
