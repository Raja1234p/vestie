import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_success_screen.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_route_args.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_copy.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_route_args.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_presentation.dart';
import 'package:vestie/features/success_vote/presentation/widgets/success_vote_outcome_amount_card.dart';
import 'package:vestie/features/success_vote/presentation/widgets/success_vote_outcome_vote_summary.dart';
import 'package:vestie/user/features/home/domain/entities/project_category_extensions.dart';

/// Shared success-vote outcome — approved or rejected (Figma).
///
/// One layout for group leader, co-leader, and member; only [SuccessVoteOutcomeCopy]
/// changes per role.
class SuccessVoteOutcomeScreen extends StatelessWidget {
  final SuccessVoteOutcomeRouteArgs args;

  const SuccessVoteOutcomeScreen({super.key, required this.args});

  void _onPrimaryPressed(BuildContext context) {
    if (args.fromCompletedProjectsList) {
      _openCompletedProjectDetail(context);
      return;
    }
    context.go(AppRoutes.dashboard);
  }

  void _openCompletedProjectDetail(BuildContext context) {
    final projectId = args.projectId ?? args.project?.id;
    if (projectId == null || projectId.trim().isEmpty) {
      context.go(AppRoutes.dashboard);
      return;
    }

    final category = args.resolvedCategory;
    final isInvestment = category?.isInvestment ?? false;
    // Profile completed list only — replace outcome load so back lands on list.
    context.pushReplacement(
      isInvestment ? AppRoutes.investmentProjectDetail : AppRoutes.projectDetail,
      extra: ProjectDetailRouteArgs(
        projectId: projectId,
        initialProjectName: ProjectDetailRouteArgs.normalizedName(
          args.initialProjectName ?? args.project?.name,
        ),
        skipCompletedOutcomeTakeover: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = args.data;
    final copy = SuccessVoteOutcomeCopy.forRole(
      args.viewerRole,
      category: args.resolvedCategory,
      variant: args.variant,
      viewerPenaltyIneligible: args.viewerPenaltyIneligible,
    );
    final resolved = SuccessVoteOutcomePresentation.resolve(
      data: data,
      copy: copy,
      refundPhase: args.refundPhase,
      variant: args.variant,
      category: args.resolvedCategory,
      viewerPenaltyIneligible: args.viewerPenaltyIneligible,
    );

    final buttonText = args.fromCompletedProjectsList
        ? AppStrings.btnViewDetails
        : AppStrings.btnBackToHome;

    final fromCompletedList = args.fromCompletedProjectsList;

    return AppSuccessScreen(
      illustrationTopSpacing: fromCompletedList ? 56.h : 40.h,
      illustrationSize: fromCompletedList ? 200.w : null,
      showBackButton: fromCompletedList,
      onBackPressed: fromCompletedList ? () => context.pop() : null,
      backButtonColor: fromCompletedList ? AppColors.surface : null,
      backButtonPadding: fromCompletedList
          ? EdgeInsets.only(left: 20.w, top: 16.h)
          : null,
      backButtonSize: fromCompletedList ? 32.w : null,
      illustrationAsset: data.isApproved
          ? AppAssets.successProjectCreated
          : AppAssets.statusFailure,
      title: resolved.title,
      subtitle: resolved.subtitle,
      customContent: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SuccessVoteOutcomeAmountCard(
            data: data,
            copy: copy,
            captionOverride: resolved.amountCaption,
            rejectedCaptionAccentRed: resolved.rejectedCaptionAccentRed,
          ),
          if (!resolved.hideVoteSummary) ...[
            SizedBox(height: 24.h),
            SuccessVoteOutcomeVoteSummary(data: data, copy: copy),
          ],
        ],
      ),
      buttonText: buttonText,
      onButtonPressed: () => _onPrimaryPressed(context),
    );
  }
}
