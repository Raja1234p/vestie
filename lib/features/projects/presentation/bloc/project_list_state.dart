import 'package:equatable/equatable.dart';
import '../../domain/entities/project_summary_entity.dart';

abstract class ProjectListState extends Equatable {
  const ProjectListState();

  @override
  List<Object?> get props => [];
}

class ProjectListInitial extends ProjectListState {}

class ProjectListLoading extends ProjectListState {}

class ProjectListLoaded extends ProjectListState {
  final List<ProjectSummaryEntity> projects;

  const ProjectListLoaded({required this.projects});

  @override
  List<Object?> get props => [projects];
}

class ProjectListFailure extends ProjectListState {
  final String message;
  final String? title;

  const ProjectListFailure({required this.message, this.title});

  @override
  List<Object?> get props => [message, title];
}
