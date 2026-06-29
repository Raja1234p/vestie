import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();
}

class HomeFetchStarted extends HomeEvent {
  const HomeFetchStarted();
  @override
  List<Object> get props => [];
}

class HomeRefreshRequested extends HomeEvent {
  /// When true, keeps the current list visible while refetching (tab reselect).
  final bool silent;

  const HomeRefreshRequested({this.silent = false});

  @override
  List<Object> get props => [silent];
}

/// Updates raised amount on a project card after contribute (201 `projectPot`).
class HomeProjectPotPatched extends HomeEvent {
  final String projectId;
  final double projectPot;

  const HomeProjectPotPatched({
    required this.projectId,
    required this.projectPot,
  });

  @override
  List<Object> get props => [projectId, projectPot];
}

/// Appends the next page of `GET /projects?scope=mine`.
class HomeLoadMoreMyProjects extends HomeEvent {
  const HomeLoadMoreMyProjects();

  @override
  List<Object> get props => [];
}
