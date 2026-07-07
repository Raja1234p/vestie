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

  /// Profile completed list → outcome → **View Details** opens this project.
  final String? completedProjectDetailId;
  final String? completedProjectName;

  const SuccessVoteOutcomeRouteArgs({
    required this.data,
    required this.viewerRole,
    this.variant = SuccessVoteOutcomeVariant.successVote,
    this.refundPhase = SuccessVoteOutcomeRefundPhase.none,
    this.distributionPhase = SuccessVoteOutcomeDistributionPhase.none,
    this.project,
    this.projectCategory,
    this.completedProjectDetailId,
    this.completedProjectName,
  });

  ProjectCategory? get resolvedCategory => projectCategory ?? project?.category;
}

/// @deprecated Use [SuccessVoteOutcomeRouteArgs].
typedef MemberVoteOutcomeRouteArgs = SuccessVoteOutcomeRouteArgs;
