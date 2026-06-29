import 'package:equatable/equatable.dart';
import '../../domain/entities/project.dart';

abstract class HomeState extends Equatable {
  const HomeState();
}

class HomeInitial extends HomeState {
  const HomeInitial();
  @override
  List<Object> get props => [];
}

class HomeLoading extends HomeState {
  const HomeLoading();
  @override
  List<Object> get props => [];
}

class HomeLoaded extends HomeState {
  final double totalContributed;
  final List<Project> myProjects;
  final List<Project> joinedProjects;
  final bool myProjectsLoadingMore;
  final int mineCurrentPage;
  final int mineTotalCount;

  const HomeLoaded({
    required this.totalContributed,
    required this.myProjects,
    required this.joinedProjects,
    this.myProjectsLoadingMore = false,
    this.mineCurrentPage = 0,
    this.mineTotalCount = 0,
  });

  bool get mineHasMore =>
      (myProjects.length + joinedProjects.length) < mineTotalCount;

  HomeLoaded copyWith({
    double? totalContributed,
    List<Project>? myProjects,
    List<Project>? joinedProjects,
    bool? myProjectsLoadingMore,
    int? mineCurrentPage,
    int? mineTotalCount,
  }) {
    return HomeLoaded(
      totalContributed: totalContributed ?? this.totalContributed,
      myProjects: myProjects ?? this.myProjects,
      joinedProjects: joinedProjects ?? this.joinedProjects,
      myProjectsLoadingMore:
          myProjectsLoadingMore ?? this.myProjectsLoadingMore,
      mineCurrentPage: mineCurrentPage ?? this.mineCurrentPage,
      mineTotalCount: mineTotalCount ?? this.mineTotalCount,
    );
  }

  @override
  List<Object> get props => [
    totalContributed,
    myProjects,
    joinedProjects,
    myProjectsLoadingMore,
    mineCurrentPage,
    mineTotalCount,
  ];
}

class HomeError extends HomeState {
  final String message;
  const HomeError({required this.message});
  @override
  List<Object> get props => [message];
}
