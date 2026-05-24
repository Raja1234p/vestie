import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/constants/storage_keys.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/error/failures.dart';
import 'package:vestie/features/auth/domain/entities/user.dart';
import 'package:vestie/features/auth/domain/usecases/get_me_use_case.dart';
import 'package:vestie/features/dashboard/domain/dashboard_prefetch.dart';
import '../../domain/entities/project.dart';
import 'package:vestie/features/projects/domain/usecases/list_projects_use_case.dart';
import '../../domain/usecases/get_user_me_summary_use_case.dart';
import 'home_event.dart';
import 'home_state.dart';

/// Handles Home data fetch.
/// Dashboard boot: `GET /projects?scope=mine` + `GET /users/me` only (see [DashboardPrefetch]).
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final ListProjectsUseCase _listProjectsUseCase;
  final GetMeUseCase _getMeUseCase;
  final GetUserMeSummaryUseCase _getUserMeSummaryUseCase;

  HomeBloc({
    ListProjectsUseCase? listProjectsUseCase,
    GetMeUseCase? getMeUseCase,
    GetUserMeSummaryUseCase? getUserMeSummaryUseCase,
  })  : _listProjectsUseCase =
            listProjectsUseCase ?? ServiceLocator.instance.listProjectsUseCase,
        _getMeUseCase = getMeUseCase ?? ServiceLocator.instance.getMeUseCase,
        _getUserMeSummaryUseCase = getUserMeSummaryUseCase ??
            ServiceLocator.instance.getUserMeSummaryUseCase,
        super(const HomeInitial()) {
    on<HomeFetchStarted>(_onFetch);
    on<HomeRefreshRequested>(_onFetch);
  }

  Future<void> _onFetch(HomeEvent event, Emitter<HomeState> emit) async {
    final silent =
        event is HomeRefreshRequested && event.silent && state is HomeLoaded;

    if (!silent) {
      emit(const HomeLoading());
    }

    final mineResult = await _listProjectsUseCase(scope: 'mine');
    final summaryResult = await _getUserMeSummaryUseCase();

    if (!DashboardPrefetch.userMeLoadedOnDashboard) {
      final meResult = await _getMeUseCase();
      meResult.fold(
        (_) {},
        (User user) {
          final userName = user.userName.isNotEmpty
              ? user.userName
              : (user.email.contains('@')
                  ? user.email.split('@').first
                  : '');
          ServiceLocator.instance.sharedPrefs
              .saveString(StorageKeys.userName, user.name);
          ServiceLocator.instance.sharedPrefs
              .saveString(StorageKeys.userEmail, user.email);
          ServiceLocator.instance.sharedPrefs
              .saveString(StorageKeys.userUsername, userName);
          DashboardPrefetch.markUserMeLoaded();
        },
      );
    }

    final mine = mineResult.fold((_) => null, (List<Project> v) => v);
    if (mine == null) {
      if (silent) return;
      final failure = mineResult.fold((f) => f, (_) => null);
      emit(HomeError(
        message: failure == null
            ? 'Failed to load projects'
            : _userFacingFailureMessage(failure),
      ));
      return;
    }

    final myProjects = mine
        .where((p) => p.relation == ProjectRelation.owned)
        .toList(growable: false);
    final joinedProjects = mine
        .where((p) => p.relation == ProjectRelation.joined)
        .toList(growable: false);

    final totalContributed = summaryResult.fold(
      (_) => 0.0,
      (summary) => summary.totalContributed,
    );

    emit(HomeLoaded(
      totalContributed: totalContributed,
      myProjects: myProjects,
      joinedProjects: joinedProjects,
    ));
  }

  String _userFacingFailureMessage(Failure failure) {
    if (failure is NetworkFailure || failure is TimeoutFailure) {
      return AppStrings.errorNetwork;
    }
    return failure.message;
  }
}
