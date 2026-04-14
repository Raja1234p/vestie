import 'package:equatable/equatable.dart';
import '../../domain/entities/project.dart';

abstract class HomeState extends Equatable {
  const HomeState();
}

class HomeInitial extends HomeState {
  const HomeInitial();
  @override List<Object> get props => [];
}

class HomeLoading extends HomeState {
  const HomeLoading();
  @override List<Object> get props => [];
}

class HomeLoaded extends HomeState {
  final double totalContributed;
  final List<Project> myProjects;
  final List<Project> joinedProjects;

  const HomeLoaded({
    required this.totalContributed,
    required this.myProjects,
    required this.joinedProjects,
  });

  @override
  List<Object> get props => [totalContributed, myProjects, joinedProjects];
}

class HomeError extends HomeState {
  final String message;
  const HomeError({required this.message});
  @override List<Object> get props => [message];
}
