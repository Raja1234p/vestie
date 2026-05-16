import 'package:equatable/equatable.dart';

import 'package:vestie/features/project_detail/domain/entities/viewer_membership_role.dart';

/// One row from `GET /projects?scope=mine|discover` (flat project object).
class ProjectSummaryEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final String type;
  final String visibility;
  /// Lifecycle state from API `state` (e.g. `active`) or mapped int.
  final String state;
  final double targetAmount;
  final double raisedAmount;
  final int maxMembers;
  final DateTime endsAtUtc;
  final DateTime? launchedAtUtc;
  final bool borrowingEnabled;
  final double? suggestedContributionAmount;
  final DateTime createdUtc;
  /// `GroupLeader` | `CoLeader` | `Member`.
  final String viewerRole;
  final String displayStatus;
  final String? projectInviteCode;
  final int pendingRequestCount;

  const ProjectSummaryEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.visibility,
    required this.state,
    required this.targetAmount,
    this.raisedAmount = 0,
    this.maxMembers = 0,
    required this.endsAtUtc,
    this.launchedAtUtc,
    required this.borrowingEnabled,
    this.suggestedContributionAmount,
    required this.createdUtc,
    this.viewerRole = '',
    this.displayStatus = '',
    this.projectInviteCode,
    this.pendingRequestCount = 0,
  });

  ViewerMembershipRole get viewerMembershipRole =>
      ViewerMembershipRole.parse(viewerRole);

  bool get isGroupLeader => viewerMembershipRole.isGroupLeader;

  bool get isCoLeader => viewerMembershipRole.isCoLeader;

  bool get isMember => viewerMembershipRole.isMember;

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        type,
        visibility,
        state,
        targetAmount,
        raisedAmount,
        maxMembers,
        endsAtUtc,
        launchedAtUtc,
        borrowingEnabled,
        suggestedContributionAmount,
        createdUtc,
        viewerRole,
        displayStatus,
        projectInviteCode,
        pendingRequestCount,
      ];
}
