import 'package:vestie/core/constants/app_strings.dart';
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
  });

  Project copyWith({
    double? currentAmount,
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
      successVoteApproved: successVoteApproved,
    );
  }

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

  /// API `displayStatus` e.g. "On Going" — member may open project detail.
  bool get isDisplayOnGoing {
    final normalized = _normalizedDisplayStatus;
    if (normalized.isEmpty) {
      return status == ProjectStatus.ongoing && !isWaitingForApproval;
    }
    return normalized == 'on going' || normalized == 'ongoing';
  }

  String get _normalizedDisplayStatus =>
      (displayStatus ?? '').trim().toLowerCase();

  /// Majority success-vote result for completed projects (profile list **View**).
  bool get isSuccessVoteApproved {
    if (successVoteApproved != null) return successVoteApproved!;
    final status = _normalizedDisplayStatus;
    if (status.contains('not approved') ||
        status.contains('reject') ||
        status.contains('cancel')) {
      return false;
    }
    return true;
  }

  /// Home / mine list card CTA (not Discover join).
  bool get showsHomeActionButton {
    if (isWaitingForApproval) return false;
    if (status == ProjectStatus.completed) {
      return relation == ProjectRelation.joined;
    }
    if (status == ProjectStatus.ongoing) {
      if (relation == ProjectRelation.joined) return isDisplayOnGoing;
      return true;
    }
    return false;
  }

  double get progress =>
      (goalAmount != null && currentAmount != null && goalAmount! > 0)
          ? (currentAmount! / goalAmount!).clamp(0.0, 1.0)
          : 0.0;
}
