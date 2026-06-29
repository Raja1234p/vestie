import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/features/profile/data/profile_prefs.dart';
import 'package:vestie/core/error/failures.dart';
import 'package:vestie/features/auth/domain/entities/user.dart';
import 'package:vestie/features/auth/domain/usecases/get_me_use_case.dart';
import 'package:vestie/core/services/home_project_list_sync.dart';
import 'package:vestie/features/dashboard/domain/dashboard_prefetch.dart';
import '../../domain/entities/project.dart';
import 'package:vestie/features/projects/domain/usecases/list_projects_use_case.dart';
import '../../domain/usecases/get_user_me_summary_use_case.dart';
import 'home_event.dart';
import 'home_state.dart';

/// Handles Home data fetch.
/// Dashboard boot: `GET /projects` + `GET /users/me/summary` (+ `GET /users/me` once per session).
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final ListProjectsUseCase _listProjectsUseCase;
  final GetMeUseCase _getMeUseCase;
  final GetUserMeSummaryUseCase _getUserMeSummaryUseCase;

  HomeBloc({
    ListProjectsUseCase? listProjectsUseCase,
    GetMeUseCase? getMeUseCase,
    GetUserMeSummaryUseCase? getUserMeSummaryUseCase,
  }) : _listProjectsUseCase =
           listProjectsUseCase ?? ServiceLocator.instance.listProjectsUseCase,
       _getMeUseCase = getMeUseCase ?? ServiceLocator.instance.getMeUseCase,
       _getUserMeSummaryUseCase =
           getUserMeSummaryUseCase ??
           ServiceLocator.instance.getUserMeSummaryUseCase,
       super(const HomeInitial()) {
    on<HomeFetchStarted>(_onFetch);
    on<HomeRefreshRequested>(_onFetch);
    on<HomeProjectPotPatched>(_onProjectPotPatched);
    on<HomeLoadMoreMyProjects>(_onLoadMoreMyProjects);
  }

  void _onProjectPotPatched(
    HomeProjectPotPatched event,
    Emitter<HomeState> emit,
  ) {
    final curr = state;
    if (curr is! HomeLoaded) return;
    if (event.projectId.isEmpty || event.projectPot <= 0) return;

    emit(
      curr.copyWith(
        myProjects: _patchProjectPot(
          curr.myProjects,
          projectId: event.projectId,
          projectPot: event.projectPot,
        ),
        joinedProjects: _patchProjectPot(
          curr.joinedProjects,
          projectId: event.projectId,
          projectPot: event.projectPot,
        ),
      ),
    );
  }

  List<Project> _patchProjectPot(
    List<Project> projects, {
    required String projectId,
    required double projectPot,
  }) {
    var updated = false;
    final next = projects
        .map((p) {
          if (p.id != projectId) return p;
          updated = true;
          return p.copyWith(currentAmount: projectPot);
        })
        .toList(growable: false);
    return updated ? next : projects;
  }

  ({List<Project> owned, List<Project> joined}) _splitMineProjects(
    List<Project> mine,
  ) {
    var myProjects = mine
        .where((p) => p.relation == ProjectRelation.owned)
        .toList(growable: false);
    var joinedProjects = mine
        .where((p) => p.relation == ProjectRelation.joined)
        .toList(growable: false);

    myProjects = HomeProjectListSync.applyPendingPots(myProjects);
    joinedProjects = HomeProjectListSync.applyPendingPots(joinedProjects);
    return (owned: myProjects, joined: joinedProjects);
  }

  Future<void> _onFetch(HomeEvent event, Emitter<HomeState> emit) async {
    final silent =
        event is HomeRefreshRequested && event.silent && state is HomeLoaded;

    if (!silent) {
      emit(const HomeLoading());
    }

    final mineResult = await _listProjectsUseCase(scope: 'mine', page: 1);
    final summaryResult = await _getUserMeSummaryUseCase();

    if (!DashboardPrefetch.userMeLoadedOnDashboard) {
      final meResult = await _getMeUseCase();
      await meResult.fold<Future<void>>((_) async {}, (User user) async {
        await ProfilePrefs.persist(ProfilePrefs.fromUser(user));
        DashboardPrefetch.markUserMeLoaded();
      });
    }

    final minePage = mineResult.fold((_) => null, (page) => page);
    if (minePage == null) {
      if (silent) return;
      final failure = mineResult.fold((f) => f, (_) => null);
      emit(
        HomeError(
          message: failure == null
              ? 'Failed to load projects'
              : _userFacingFailureMessage(failure),
        ),
      );
      return;
    }

    final split = _splitMineProjects(minePage.items);
    HomeProjectListSync.reconcileAfterFetch([
      ...split.owned,
      ...split.joined,
    ]);

    final totalContributed = summaryResult.fold(
      (_) => 0.0,
      (summary) => summary.totalContributed,
    );

    emit(
      HomeLoaded(
        totalContributed: totalContributed,
        myProjects: split.owned,
        joinedProjects: split.joined,
        mineCurrentPage: minePage.page,
        mineTotalCount: minePage.totalCount,
      ),
    );
  }

  Future<void> _onLoadMoreMyProjects(
    HomeLoadMoreMyProjects event,
    Emitter<HomeState> emit,
  ) async {
    final curr = state;
    if (curr is! HomeLoaded) return;
    if (curr.myProjectsLoadingMore || !curr.mineHasMore) return;

    emit(curr.copyWith(myProjectsLoadingMore: true));
    final nextPage = curr.mineCurrentPage + 1;
    final result = await _listProjectsUseCase(scope: 'mine', page: nextPage);

    await result.fold(
      (failure) async {
        if (state is HomeLoaded) {
          emit((state as HomeLoaded).copyWith(myProjectsLoadingMore: false));
        }
      },
      (page) async {
        final latest = state;
        if (latest is! HomeLoaded) return;

        final existingIds = {
          ...latest.myProjects.map((p) => p.id),
          ...latest.joinedProjects.map((p) => p.id),
        };
        final newItems = page.items
            .where((p) => !existingIds.contains(p.id))
            .toList(growable: false);
        final split = _splitMineProjects(newItems);

        emit(
          latest.copyWith(
            myProjects: [...latest.myProjects, ...split.owned],
            joinedProjects: [...latest.joinedProjects, ...split.joined],
            myProjectsLoadingMore: false,
            mineCurrentPage: page.page,
            mineTotalCount: page.totalCount,
          ),
        );
      },
    );
  }

  String _userFacingFailureMessage(Failure failure) {
    if (failure is NetworkFailure || failure is TimeoutFailure) {
      return AppStrings.errorNetwork;
    }
    return failure.message;
  }
}
