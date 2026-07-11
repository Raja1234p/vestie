import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_distribution_phase.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_refund_phase.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_role.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_ui_data.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_variant.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';

/// Route args for [SuccessVoteOutcomeScreen] (approved / rejected).
class SuccessVoteOutcomeRouteArgs {
  final SuccessVoteOutcomeUiData data;
  final SuccessVoteOutcomeRole viewerRole;
  final SuccessVoteOutcomeVariant variant;
  final SuccessVoteOutcomeRefundPhase refundPhase;
  final SuccessVoteOutcomeDistributionPhase distributionPhase;

  /// Full project detail — used for moderator navigation context.
  final ProjectDetailEntity? project;

  /// Used for category-specific copy when [project] is null.
  final ProjectCategory? projectCategory;

  /// Defaulted / overdue viewer — penalty-specific outcome copy (no wallet refund).
  final bool viewerPenaltyIneligible;

  /// Profile → Completed Projects: primary CTA opens read-only detail (not dashboard).
  final bool fromCompletedProjectsList;

  /// Navigation when [fromCompletedProjectsList] is true.
  final String? projectId;
  final String? initialProjectName;

  const SuccessVoteOutcomeRouteArgs({
    required this.data,
    required this.viewerRole,
    this.variant = SuccessVoteOutcomeVariant.successVote,
    this.refundPhase = SuccessVoteOutcomeRefundPhase.none,
    this.distributionPhase = SuccessVoteOutcomeDistributionPhase.none,
    this.project,
    this.projectCategory,
    this.viewerPenaltyIneligible = false,
    this.fromCompletedProjectsList = false,
    this.projectId,
    this.initialProjectName,
  });

  SuccessVoteOutcomeRouteArgs copyWith({
    bool? fromCompletedProjectsList,
    String? projectId,
    String? initialProjectName,
  }) {
    return SuccessVoteOutcomeRouteArgs(
      data: data,
      viewerRole: viewerRole,
      variant: variant,
      refundPhase: refundPhase,
      distributionPhase: distributionPhase,
      project: project,
      projectCategory: projectCategory,
      viewerPenaltyIneligible: viewerPenaltyIneligible,
      fromCompletedProjectsList:
          fromCompletedProjectsList ?? this.fromCompletedProjectsList,
      projectId: projectId ?? this.projectId,
      initialProjectName: initialProjectName ?? this.initialProjectName,
    );
  }

  ProjectCategory? get resolvedCategory => projectCategory ?? project?.category;
}

/// @deprecated Use [SuccessVoteOutcomeRouteArgs].
typedef MemberVoteOutcomeRouteArgs = SuccessVoteOutcomeRouteArgs;
