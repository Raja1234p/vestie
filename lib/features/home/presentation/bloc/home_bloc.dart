import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/mock_projects.dart';
import 'home_event.dart';
import 'home_state.dart';

/// Handles Home data fetch.
/// TODO: Inject HomeRepository when API layer is ready.
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeInitial()) {
    on<HomeFetchStarted>(_onFetch);
    on<HomeRefreshRequested>(_onFetch);
  }

  Future<void> _onFetch(HomeEvent event, Emitter<HomeState> emit) async {
    emit(const HomeLoading());
    await Future.delayed(const Duration(milliseconds: 800));
    // TODO: Replace with repository call
    emit(const HomeLoaded(
      totalContributed: 4223,
      myProjects: MockProjects.myProjects,
      joinedProjects: MockProjects.joinedProjects,
    ));
  }
}
