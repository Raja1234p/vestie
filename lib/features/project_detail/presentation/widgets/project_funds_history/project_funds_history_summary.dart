import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/utils/formatters.dart';
import 'package:vestie/core/widgets/common/app_metric_tile.dart';
import 'package:vestie/core/widgets/text/app_text.dart';

/// Investment: pot balance + Breakdown. Pooled: balance, metrics, contribution history.
enum ProjectFundsHistorySummaryLayout {
  investment,
  pooled,
}

class ProjectFundsHistorySummary extends StatelessWidget {
  final double currentPotBalance;
  final ProjectFundsHistorySummaryLayout layout;
  final double totalContribution;
  final double activeBorrows;

  const ProjectFundsHistorySummary({
    super.key,
    required this.currentPotBalance,
    this.layout = ProjectFundsHistorySummaryLayout.pooled,
    this.totalContribution = 0,
    this.activeBorrows = 0,
  });

  @override
  Widget build(BuildContext context) {
    final listTitle = layout == ProjectFundsHistorySummaryLayout.investment
        ? AppStrings.labelBreakdown
        : AppStrings.projectFundsContributionHistory;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          AppStrings.projectFundsCurrentPotBalance,
          style: GoogleFonts.lato(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.projectFundsMetricValue,
          ),
        ),
        SizedBox(height: 4.h),
        AppText(
          AppFormatters.formatCurrency(currentPotBalance),
          style: GoogleFonts.lato(
            fontSize: 32.sp,
            fontWeight: FontWeight.w900,
            color: AppColors.projectFundsMetricValue,
            height: 1.15,
          ),
        ),
        if (layout == ProjectFundsHistorySummaryLayout.pooled) ...[
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: AppMetricTile(
                  label: AppStrings.projectFundsTotalContribution,
                  value: AppFormatters.formatCurrency(totalContribution),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: AppMetricTile(
                  label: AppStrings.projectFundsActiveBorrows,
                  value: AppFormatters.formatCurrency(activeBorrows),
                ),
              ),
            ],
          ),
        ],
        SizedBox(height: 20.h),
        AppText(
          listTitle,
          style: GoogleFonts.lato(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.projectFundsMetricValue,
          ),
        ),
        SizedBox(height: 12.h),
      ],
    );
  }
}
