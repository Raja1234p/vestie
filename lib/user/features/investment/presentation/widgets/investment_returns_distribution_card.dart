import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/features/project_detail/presentation/models/investment_returns_ui_data.dart';

/// Payment history card — header + divider + two-column amounts (Figma).
class InvestmentReturnsDistributionCard extends StatelessWidget {
  final InvestmentDistributionUi distribution;

  const InvestmentReturnsDistributionCard({
    super.key,
    required this.distribution,
  });

  @override
  Widget build(BuildContext context) {
    final d = distribution;
    final leaderFormatted =
        '+\$${InvestmentReturnsUiData.formatMoney(d.leaderDistributionUsd)}';
    final shareFormatted =
        '\$${InvestmentReturnsUiData.formatMoney(d.myShareUsd)}';
    final leftCaption =
        d.leftColumnCaption ?? AppStrings.investmentLeaderDistributionLabel;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.neutral500),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.vertical(top: Radius.circular(14.r)),
            ),
            padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  AppStrings.investmentDistributionTitle(d.distributionNumber),
                  style: GoogleFonts.lato(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.grey1100,
                  ),
                ),
                SizedBox(height: 2.h),
                AppText(
                  d.dateLabel,
                  style: GoogleFonts.lato(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey800,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: AppColors.neutral500,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 14.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _DistributionMetricColumn(
                    label: leftCaption,
                    value: leaderFormatted,
                    valueColor: AppColors.neutral1200,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _DistributionMetricColumn(
                    label: AppStrings.investmentMyShareLabel,
                    value: shareFormatted,
                    valueColor: AppColors.green900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DistributionMetricColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _DistributionMetricColumn({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          label,
          style: GoogleFonts.lato(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.grey800,
          ),
        ),
        SizedBox(height: 4.h),
        AppText(
          value,
          style: GoogleFonts.lato(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
