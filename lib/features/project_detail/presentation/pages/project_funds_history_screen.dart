import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/common/post_auth_header.dart';
import 'package:vestie/core/widgets/text/app_text.dart';

import 'package:vestie/app/router/route_args/project_detail_flow_args.dart';
import '../widgets/project_funds_history/project_funds_history_row.dart';
import '../widgets/project_funds_history/project_funds_history_summary.dart';

/// Pooled pot ledger for vacation / emergency project detail.
class ProjectFundsHistoryScreen extends StatelessWidget {
  final ProjectFundsHistoryRouteArgs args;

  const ProjectFundsHistoryScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PostAuthGradientBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PostAuthHeader(
              title: AppStrings.menuProjectFundsHistory,
              leading: AppBackButton(onPressed: () => context.pop()),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 32.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProjectFundsHistorySummary(
                      currentPotBalance: args.currentPotBalance,
                      layout: args.isInvestment
                          ? ProjectFundsHistorySummaryLayout.investment
                          : ProjectFundsHistorySummaryLayout.pooled,
                      totalContribution: args.totalContribution,
                      activeBorrows: args.activeBorrows,
                    ),
                    if (args.entries.isEmpty)
                      _EmptyLedgerCard()
                    else
                      ...args.entries.map(
                        (e) => ProjectFundsHistoryRow(entry: e),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyLedgerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 28.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.projectFundsLedgerCardBg,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: AppColors.projectFundsLedgerBorder,
          width: 1,
        ),
      ),
      child: AppText(
        AppStrings.projectFundsHistoryEmpty,
        textAlign: TextAlign.center,
        style: GoogleFonts.lato(
          fontSize: 15.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.grey800,
        ),
      ),
    );
  }
}
