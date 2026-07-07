import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/utils/project_gallery_image_urls.dart';
import 'package:vestie/features/project_detail/domain/entities/viewer_membership_role.dart';
import 'package:vestie/features/projects/domain/entities/project_image_entity.dart';

import 'user_flow_on_open.dart';
import 'project_category_extensions.dart';

export 'user_flow_on_open.dart';

enum ProjectCategory { vacations, emergency, investment }

enum ProjectStatus { ongoing, completed }

enum ProjectRelation { owned, joined }

class Project {
  final String id;
  final String name;
  final ProjectCategory category;
  final ProjectStatus status;
  final ProjectRelation relation;
  final double? goalAmount;
  final double? currentAmount;
  final String? endsIn;
  final double? roiPercentage;
  final String? description;
  final String? displayStatus;
  final String? projectInviteCode;
  final bool requestPending;

  /// Discover join CTA — `true` when API visibility is Public (1).
  final bool isPublic;

  /// Mock: member-only — which full-screen flow opens instead of project detail.
  final UserFlowOnOpen? userFlow;

  /// When set, drives completed-project **View** → vote outcome (approved / not).
  final bool? successVoteApproved;

  /// List API — last finalized vote type (`SuccessVote`, etc.).
  final String? lastVoteType;

  /// List API — last finalized vote outcome (`Success`, `Refund`, etc.).
  final String? lastVoteOutcome;

  /// List API — `voting.distributionStatus` mirror (`InProgress` / `Complete`).
  final String? distributionStatus;

  /// `coverImageUrl` from `GET /projects` — category illustration when empty.
  final String? coverImageUrl;

  /// API `viewerRole` on list rows — drives completed outcome copy.
  final ViewerMembershipRole viewerRole;

  /// `memberCount` / `maxMembers` from list payloads — vote summary denominator.
  final int memberCount;

  final List<ProjectImageEntity> images;

  const Project({
    required this.id,
    required this.name,
    required this.category,
    required this.status,
    required this.relation,
    this.goalAmount,
    this.currentAmount,
    this.endsIn,
    this.roiPercentage,
    this.description,
    this.displayStatus,
    this.projectInviteCode,
    this.requestPending = false,
    this.isPublic = true,
    this.userFlow,
    this.successVoteApproved,
    this.lastVoteType,
    this.lastVoteOutcome,
    this.distributionStatus,
    this.coverImageUrl,
    this.viewerRole = ViewerMembershipRole.member,
    this.memberCount = 0,
    this.images = const [],
  });

  Project copyWith({
    double? currentAmount,
    String? coverImageUrl,
    ViewerMembershipRole? viewerRole,
    int? memberCount,
    bool? successVoteApproved,
    String? lastVoteType,
    String? lastVoteOutcome,
    String? distributionStatus,
  }) {
    return Project(
      id: id,
      name: name,
      category: category,
      status: status,
      relation: relation,
      goalAmount: goalAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      endsIn: endsIn,
      roiPercentage: roiPercentage,
      description: description,
      displayStatus: displayStatus,
      projectInviteCode: projectInviteCode,
      requestPending: requestPending,
      isPublic: isPublic,
      userFlow: userFlow,
      successVoteApproved: successVoteApproved ?? this.successVoteApproved,
      lastVoteType: lastVoteType ?? this.lastVoteType,
      lastVoteOutcome: lastVoteOutcome ?? this.lastVoteOutcome,
      distributionStatus: distributionStatus ?? this.distributionStatus,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      viewerRole: viewerRole ?? this.viewerRole,
      memberCount: memberCount ?? this.memberCount,
      images: images,
    );
  }

  List<String> get galleryImageUrls => ProjectGalleryImageUrls.resolve(
    coverImageUrl: coverImageUrl,
    images: images,
  );

  String get categoryLabel {
    return category.label;
  }

  String get statusLabel {
    if (displayStatus != null && displayStatus!.trim().isNotEmpty) {
      return displayStatus!.trim();
    }
    return status == ProjectStatus.ongoing
        ? AppStrings.statusOnGoing
        : AppStrings.statusCompleted;
  }

  bool get isDraft => displayStatus?.toLowerCase() == 'draft';

  /// API `displayStatus` e.g. "Waiting for Approval" (joined member, pending).
  bool get isWaitingForApproval {
    final normalized = _normalizedDisplayStatus;
    return normalized.contains('waiting') && normalized.contains('approval');
  }

  /// API `displayStatus` e.g. "On Going" or "Funded" — joined member may open detail from Home.
  bool get isDisplayOnGoing {
    final normalized = _normalizedDisplayStatus;
    if (normalized.isEmpty) {
      return status == ProjectStatus.ongoing && !isWaitingForApproval;
    }
    return normalized == 'on going' ||
        normalized == 'ongoing' ||
        normalized == 'funded';
  }

  String get _normalizedDisplayStatus =>
      (displayStatus ?? '').trim().toLowerCase();

  /// API `displayStatus` e.g. "Closure Voting" — member may open project detail from Home.
  bool get isClosureVotingDisplayStatus {
    final normalized = _normalizedDisplayStatus;
    return normalized.contains('closure') && normalized.contains('voting');
  }

  /// Majority success-vote result for completed projects (profile list **View**).
  bool get isSuccessVoteApproved {
    if (successVoteApproved != null) return successVoteApproved!;
    final status = _normalizedDisplayStatus;
    if (status.contains('not approved') ||
        status.contains('reject') ||
        status.contains('cancel') ||
        status.contains('refund')) {
      return false;
    }
    return true;
  }

  /// Home / mine list card CTA (not Discover join).
  bool get showsHomeActionButton {
    if (isWaitingForApproval) return false;
    if (status == ProjectStatus.completed) return true;
    if (status == ProjectStatus.ongoing) {
      if (relation == ProjectRelation.joined) {
        return isDisplayOnGoing || isClosureVotingDisplayStatus;
      }
      return true;
    }
    return false;
  }

  double get progress =>
      (goalAmount != null && currentAmount != null && goalAmount! > 0)
      ? (currentAmount! / goalAmount!).clamp(0.0, 1.0)
      : 0.0;

  /// Investment — contribution phase ended after stop-contributions vote (Funded).
  bool get investmentContributionsAreClosed {
    if (!category.isInvestment) return false;
    final normalized = _normalizedDisplayStatus;
    return normalized == 'funded' || normalized.contains('funded');
  }
}
