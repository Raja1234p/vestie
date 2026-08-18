import 'package:equatable/equatable.dart';

import 'package:vestie/features/project_detail/domain/entities/viewer_membership_role.dart';
import 'project_image_entity.dart';

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

  /// When present on list project object (including `0`); otherwise [raisedAmount].
  final double? potAmount;

  final double totalContributed;

  /// Refund due to the viewer when pot/raised/contributions are zero (cancelled/refund).
  final double viewerRefundAmount;
  final int maxMembers;
  final DateTime? endsAtUtc;
  final DateTime? launchedAtUtc;
  final bool borrowingEnabled;
  final double? suggestedContributionAmount;
  final DateTime createdUtc;

  /// `GroupLeader` | `CoLeader` | `Member`.
  final String viewerRole;
  final String displayStatus;
  final String? projectInviteCode;
  final int pendingRequestCount;
  final double? roiPercentage;
  final String? coverImageUrl;
  final List<ProjectImageEntity> images;
  final bool? successVoteApproved;
  final String? lastVoteType;
  final String? lastVoteOutcome;
  final int eligibleMemberCount;
  final int totalJoinedMember;
  final String? distributionStatus;

  const ProjectSummaryEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.visibility,
    required this.state,
    required this.targetAmount,
    this.raisedAmount = 0,
    this.potAmount,
    this.totalContributed = 0,
    this.viewerRefundAmount = 0,
    this.maxMembers = 0,
    this.endsAtUtc,
    this.launchedAtUtc,
    required this.borrowingEnabled,
    this.suggestedContributionAmount,
    required this.createdUtc,
    this.viewerRole = '',
    this.displayStatus = '',
    this.projectInviteCode,
    this.pendingRequestCount = 0,
    this.roiPercentage,
    this.coverImageUrl,
    this.images = const [],
    this.successVoteApproved,
    this.lastVoteType,
    this.lastVoteOutcome,
    this.eligibleMemberCount = 0,
    this.totalJoinedMember = 0,
    this.distributionStatus,
  });

  ViewerMembershipRole get viewerMembershipRole =>
      ViewerMembershipRole.parse(viewerRole);

  bool get isGroupLeader => viewerMembershipRole.isGroupLeader;

  bool get isCoLeader => viewerMembershipRole.isCoLeader;

  bool get isMember => viewerMembershipRole.isMember;

  /// `potAmount` when API sends it (including `0`); otherwise [raisedAmount].
  double get displayPotAmount => potAmount ?? raisedAmount;

  /// Home/detail card amount: pot → raised → contributed → viewer refund.
  double get raisedDisplayAmount {
    if (displayPotAmount > 0) return displayPotAmount;
    if (totalContributed > 0) return totalContributed;
    return viewerRefundAmount;
  }

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
    potAmount,
    totalContributed,
    viewerRefundAmount,
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
    roiPercentage,
    coverImageUrl,
    images,
    successVoteApproved,
    lastVoteType,
    lastVoteOutcome,
    eligibleMemberCount,
    totalJoinedMember,
    distributionStatus,
  ];
}
