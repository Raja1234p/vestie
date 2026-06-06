import 'package:equatable/equatable.dart';

class ProjectDetailEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final String type;
  final String visibility;
  final String state;
  final double targetAmount;
  final double currentAmount;
  final int maxMembers;
  final int currentMembers;
  final DateTime endsAtUtc;
  final DateTime? launchedAtUtc;
  final bool borrowingEnabled;
  final double suggestedContributionAmount;
  final ViewerMembershipEntity viewerMembership;
  final ProjectRulesEntity rules;

  const ProjectDetailEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.visibility,
    required this.state,
    required this.targetAmount,
    required this.currentAmount,
    required this.maxMembers,
    required this.currentMembers,
    required this.endsAtUtc,
    this.launchedAtUtc,
    required this.borrowingEnabled,
    required this.suggestedContributionAmount,
    required this.viewerMembership,
    required this.rules,
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
    currentAmount,
    maxMembers,
    currentMembers,
    endsAtUtc,
    launchedAtUtc,
    borrowingEnabled,
    suggestedContributionAmount,
    viewerMembership,
    rules,
  ];
}

class ViewerMembershipEntity extends Equatable {
  final String role;
  final String status;

  const ViewerMembershipEntity({required this.role, required this.status});

  bool get isLeader => role == 'Leader';

  @override
  List<Object?> get props => [role, status];
}

class ProjectRulesEntity extends Equatable {
  final double minimumContributionAmount;
  final double platformFeeRatePercent;

  const ProjectRulesEntity({
    required this.minimumContributionAmount,
    required this.platformFeeRatePercent,
  });

  @override
  List<Object?> get props => [
    minimumContributionAmount,
    platformFeeRatePercent,
  ];
}
