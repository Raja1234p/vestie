import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
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
    final discoverResult = await _listProjectsUseCase(scope: 'discover');

    final mine = mineResult.fold((_) => null, (v) => v);
    final discover = discoverResult.fold((_) => null, (v) => v);

    if (mine == null && discover == null) {
      final failure = mineResult.fold((f) => f, (_) => null) ??
          discoverResult.fold((f) => f, (_) => null);
      emit(HomeError(message: failure?.message ?? 'Failed to load projects'));
      return;
    }

    emit(HomeLoaded(
      // TODO (backend): wire real total contributed API when available.
      totalContributed: 0,
      myProjects: mine ?? const [],
      // UI currently treats "joined projects" separately; map discover here for now.
      joinedProjects: discover ?? const [],
    ));
  }
}
