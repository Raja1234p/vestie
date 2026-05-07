import 'package:equatable/equatable.dart';

class ProjectSummaryEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final String type;
  final String visibility;
  final String state;
  final double targetAmount;
  final int maxMembers;
  final DateTime endsAtUtc;
  final DateTime? launchedAtUtc;
  final bool borrowingEnabled;
  final double suggestedContributionAmount;
  final DateTime createdUtc;
  final String viewerRole;

  const ProjectSummaryEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.visibility,
    required this.state,
    required this.targetAmount,
    required this.maxMembers,
    required this.endsAtUtc,
    this.launchedAtUtc,
    required this.borrowingEnabled,
    required this.suggestedContributionAmount,
    required this.createdUtc,
    this.viewerRole = '',
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        type,
        visibility,
        state,
        targetAmount,
        maxMembers,
        endsAtUtc,
        launchedAtUtc,
        borrowingEnabled,
        suggestedContributionAmount,
        createdUtc,
        viewerRole,
      ];
}
