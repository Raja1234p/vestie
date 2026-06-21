import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/app/router/route_args/project_detail_flow_args.dart';
import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/widgets/common/app_success_screen.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_copy.dart';
import 'package:vestie/features/success_vote/presentation/widgets/success_vote_outcome_amount_card.dart';
import 'package:vestie/features/success_vote/presentation/widgets/success_vote_outcome_vote_summary.dart';

/// Shared success-vote outcome — approved or rejected (Figma).
///
/// One layout for group leader, co-leader, and member; only [SuccessVoteOutcomeCopy]
/// changes per role.
class SuccessVoteOutcomeScreen extends StatelessWidget {
  final SuccessVoteOutcomeRouteArgs args;

  const SuccessVoteOutcomeScreen({super.key, required this.args});

  void _onPrimaryPressed(BuildContext context) {
    final data = args.data;
    final copy = SuccessVoteOutcomeCopy.forRole(
      args.viewerRole,
      category: args.resolvedCategory,
      variant: args.variant,
    );
    final button = copy.primaryButtonFor(data.isApproved);

    if (button == AppStrings.btnResumeContributions && context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    final data = args.data;
    final copy = SuccessVoteOutcomeCopy.forRole(
      args.viewerRole,
      category: args.resolvedCategory,
      variant: args.variant,
    );

    return AppSuccessScreen(
      illustrationTopSpacing: 40.h,
      illustrationAsset: data.isApproved
          ? AppAssets.successProjectCreated
          : AppAssets.statusFailure,
      title: copy.titleFor(data.isApproved),
      subtitle: copy.subtitleFor(data.isApproved),
      customContent: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SuccessVoteOutcomeAmountCard(data: data, copy: copy),
          SizedBox(height: 24.h),
          SuccessVoteOutcomeVoteSummary(data: data, copy: copy),
        ],
      ),
      buttonText: copy.primaryButtonFor(data.isApproved),
      onButtonPressed: () => _onPrimaryPressed(context),
    );
  }
}
