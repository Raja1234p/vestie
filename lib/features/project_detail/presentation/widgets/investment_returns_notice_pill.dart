import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_svg_icon.dart';
import 'package:vestie/core/widgets/text/app_text.dart';

/// Member funded-phase callout below [AppStrings.btnInvestmentReturns] (Figma).
class InvestmentReturnsNoticePill extends StatelessWidget {
  const InvestmentReturnsNoticePill({super.key});

  static double get _iconSize => 20.w;

  static double get _iconGap => 8.w;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
      fontSize: 16.sp,
      fontWeight: FontWeight.w600,
      color: AppColors.grey900,
      height: 1.3,
    );
    final bodyStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
      fontSize: 14.sp,
      fontWeight: FontWeight.w500,
      color: AppColors.grey900,
      height: 1.45,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.purple100,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSvgIcon(
                assetPath: AppAssets.iconInfoCircle,
                size: _iconSize,
                color: AppColors.blue1000,
              ),
              SizedBox(width: _iconGap),
              Expanded(
                child: AppText(
                  AppStrings.investmentReturnsNoticeTitle,
                  style: titleStyle,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Padding(
            padding: EdgeInsets.only(left: _iconSize + _iconGap),
            child: AppText(
              AppStrings.investmentReturnsNoticeBody,
              style: bodyStyle,
            ),
          ),
        ],
      ),
    );
  }
}
