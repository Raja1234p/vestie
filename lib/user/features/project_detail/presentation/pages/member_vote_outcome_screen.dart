import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/app/router/route_args/project_detail_flow_args.dart';
import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/widgets/common/app_success_screen.dart';
import 'package:vestie/user/features/project_detail/presentation/widgets/member_vote_outcome/member_vote_outcome_amount_card.dart';
import 'package:vestie/user/features/project_detail/presentation/widgets/member_vote_outcome/member_vote_outcome_vote_summary.dart';

/// Member: majority vote result — project approved or not approved (Figma).
class MemberVoteOutcomeScreen extends StatelessWidget {
  final MemberVoteOutcomeRouteArgs args;

  const MemberVoteOutcomeScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    final data = args.data;

    return AppSuccessScreen(
      illustrationTopSpacing: 40.h,
      illustrationAsset: data.isApproved
          ? AppAssets.projectCreatedImage
          : AppAssets.failureIcon,
      title: data.isApproved
          ? AppStrings.projectVoteApprovedTitle
          : AppStrings.projectVoteNotApprovedTitle,
      subtitle: data.isApproved
          ? AppStrings.projectVoteApprovedSubtitle
          : AppStrings.projectVoteNotApprovedSubtitle,
      customContent: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MemberVoteOutcomeAmountCard(data: data),
          SizedBox(height: 24.h),
          MemberVoteOutcomeVoteSummary(data: data),
        ],
      ),
      buttonText: AppStrings.btnBackToHome,
      onButtonPressed: () => context.go(AppRoutes.dashboard),
    );
  }
}
