import 'package:equatable/equatable.dart';

abstract class ProjectListEvent extends Equatable {
  const ProjectListEvent();

  @override
  List<Object?> get props => [];
}

class LoadProjectsEvent extends ProjectListEvent {
  final String scope;
  final bool isRefresh;

  const LoadProjectsEvent({required this.scope, this.isRefresh = false});

  @override
  List<Object?> get props => [scope, isRefresh];
}
