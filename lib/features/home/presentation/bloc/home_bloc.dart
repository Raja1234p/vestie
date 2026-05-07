import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../domain/entities/project.dart';
import '../../../projects/domain/usecases/list_projects_use_case.dart';
import 'home_event.dart';
import 'home_state.dart';

/// Handles Home data fetch.
/// Uses Projects API via [ListProjectsUseCase].
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final ListProjectsUseCase _listProjectsUseCase;

  HomeBloc({ListProjectsUseCase? listProjectsUseCase})
      : _listProjectsUseCase =
            listProjectsUseCase ?? ServiceLocator.instance.listProjectsUseCase,
        super(const HomeInitial()) {
    on<HomeFetchStarted>(_onFetch);
    on<HomeRefreshRequested>(_onFetch);
  }

  Future<void> _onFetch(HomeEvent event, Emitter<HomeState> emit) async {
    emit(const HomeLoading());

    final mineResult = await _listProjectsUseCase(scope: 'mine');
    final mine = mineResult.fold((_) => null, (v) => v);

    if (mine == null) {
      final failure = mineResult.fold((f) => f, (_) => null);
      emit(HomeError(message: failure?.message ?? 'Failed to load projects'));
      return;
    }

    final myProjects = mine
        .where((p) => p.relation == ProjectRelation.owned)
        .toList(growable: false);
    final joinedProjects = mine
        .where((p) => p.relation == ProjectRelation.joined)
        .toList(growable: false);

    emit(HomeLoaded(
      // TODO (backend): wire real total contributed API when available.
      totalContributed: 0,
      myProjects: myProjects,
      joinedProjects: joinedProjects,
    ));
  }
}
