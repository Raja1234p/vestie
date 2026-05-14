import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vestie/core/constants/storage_keys.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/error/failures.dart';
import 'package:vestie/features/auth/domain/entities/user.dart';
import 'package:vestie/features/auth/domain/usecases/get_me_use_case.dart';
import 'package:vestie/features/dashboard/domain/dashboard_prefetch.dart';
import '../../domain/entities/project.dart';
import 'package:vestie/features/projects/domain/usecases/list_projects_use_case.dart';
import 'home_event.dart';
import 'home_state.dart';

/// Handles Home data fetch.
/// Dashboard boot: `GET /projects?scope=mine` + `GET /users/me` only (see [DashboardPrefetch]).
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final ListProjectsUseCase _listProjectsUseCase;
  final GetMeUseCase _getMeUseCase;

  HomeBloc({
    ListProjectsUseCase? listProjectsUseCase,
    GetMeUseCase? getMeUseCase,
  })  : _listProjectsUseCase =
            listProjectsUseCase ?? ServiceLocator.instance.listProjectsUseCase,
        _getMeUseCase = getMeUseCase ?? ServiceLocator.instance.getMeUseCase,
        super(const HomeInitial()) {
    on<HomeFetchStarted>(_onFetch);
    on<HomeRefreshRequested>(_onFetch);
  }

  Future<void> _onFetch(HomeEvent event, Emitter<HomeState> emit) async {
    emit(const HomeLoading());

    final results = await Future.wait<Object>([
      _listProjectsUseCase(scope: 'mine'),
      _getMeUseCase(),
    ]);

    final mineResult = results[0] as Either<Failure, List<Project>>;
    final meResult = results[1] as Either<Failure, User>;

    meResult.fold(
      (_) {},
      (User user) {
        ServiceLocator.instance.sharedPrefs
            .saveString(StorageKeys.userName, user.name);
        ServiceLocator.instance.sharedPrefs
            .saveString(StorageKeys.userEmail, user.email);
        DashboardPrefetch.markUserMeLoaded();
      },
    );

    final mine = mineResult.fold((_) => null, (List<Project> v) => v);
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
      totalContributed: 0,
      myProjects: myProjects,
      joinedProjects: joinedProjects,
    ));
  }
}
