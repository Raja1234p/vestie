import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/app/router/route_args/project_detail_flow_args.dart';
import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/widgets/common/app_success_screen.dart';
import 'package:vestie/features/project_detail/presentation/models/investment_returns_ui_data.dart';
import 'package:vestie/features/project_detail/presentation/navigation/project_detail_navigation.dart';
import 'package:vestie/user/features/project_detail/presentation/widgets/member_vote_outcome/member_vote_outcome_amount_card.dart';
import 'package:vestie/user/features/project_detail/presentation/widgets/member_vote_outcome/member_vote_outcome_vote_summary.dart';

/// Success-vote result — project approved or not approved (Figma).
///
/// Member: amount card + “Back to Home”.
/// Group leader (vacation / emergency): vote summary only;
/// “Start Distributing” or “Resume Contributions”.
class MemberVoteOutcomeScreen extends StatelessWidget {
  final MemberVoteOutcomeRouteArgs args;

  const MemberVoteOutcomeScreen({super.key, required this.args});

  void _onPrimaryPressed(BuildContext context) {
    final data = args.data;
    if (args.isGroupLeaderView) {
      if (data.isApproved) {
        final project = args.project;
        if (project != null) {
          ProjectDetailNavigation.openDistributeFundsFlow(
            context,
            returnsData: InvestmentReturnsUiData.previewLeaderForProject(project),
          );
        } else if (context.canPop()) {
          context.pop();
        }
      } else if (context.canPop()) {
        context.pop();
      }
      return;
    }
    context.go(AppRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    final data = args.data;
    final isGroupLeader = args.isGroupLeaderView;

    final buttonText = isGroupLeader
        ? (data.isApproved
            ? AppStrings.btnStartDistributing
            : AppStrings.btnResumeContributions)
        : AppStrings.btnViewDetails;

    return AppSuccessScreen(
      illustrationTopSpacing: 40.h,
      illustrationAsset: data.isApproved
          ? AppAssets.successProjectCreated
          : AppAssets.statusFailure,
      title: data.isApproved
          ? AppStrings.projectVoteApprovedTitle
          : AppStrings.projectVoteNotApprovedTitle,
      subtitle: data.isApproved
          ? AppStrings.projectVoteApprovedSubtitle
          : AppStrings.projectVoteNotApprovedSubtitle,
      customContent: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isGroupLeader) ...[
            MemberVoteOutcomeAmountCard(data: data),
            SizedBox(height: 24.h),
          ],
          MemberVoteOutcomeVoteSummary(data: data),
        ],
      ),
      buttonText: buttonText,
      onButtonPressed: () => _onPrimaryPressed(context),
    );
  }
}
