import 'package:equatable/equatable.dart';

/// Server → client SignalR events on `/hubs/projects`.
enum ProjectRealtimeEventKind { contributionMade, potUpdated, unknown }

class ProjectRealtimeEvent extends Equatable {
  const ProjectRealtimeEvent({
    required this.kind,
    required this.projectId,
    this.potAmount,
    this.contributorCount,
  });

  final ProjectRealtimeEventKind kind;
  final String projectId;
  final double? potAmount;
  final int? contributorCount;

  @override
  List<Object?> get props => [kind, projectId, potAmount, contributorCount];
}
