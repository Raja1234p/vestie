import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_projects_usecase.dart';
import 'project_list_event.dart';
import 'project_list_state.dart';

class ProjectListBloc extends Bloc<ProjectListEvent, ProjectListState> {
  final GetProjectsUseCase getProjectsUseCase;

  ProjectListBloc({required this.getProjectsUseCase})
    : super(ProjectListInitial()) {
    on<LoadProjectsEvent>(_onLoadProjects);
  }

  Future<void> _onLoadProjects(
    LoadProjectsEvent event,
    Emitter<ProjectListState> emit,
  ) async {
    if (!event.isRefresh) {
      emit(ProjectListLoading());
    }

    final result = await getProjectsUseCase(scope: event.scope);

    result.fold(
      (failure) => emit(
        ProjectListFailure(message: failure.message, title: failure.title),
      ),
      (projects) => emit(ProjectListLoaded(projects: projects)),
    );
  }
}
