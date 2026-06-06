import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/text/app_text.dart';

/// Yellow “Majority needed…” banner (Figma leader success vote).
class LeaderSuccessVoteMajorityBanner extends StatelessWidget {
  final int majorityRequired;
  final int totalMembers;

  const LeaderSuccessVoteMajorityBanner({
    super.key,
    required this.majorityRequired,
    required this.totalMembers,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.borrowPendingBannerBg,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: AppText(
        AppStrings.leaderSuccessVoteMajorityNeeded(
          majorityRequired,
          totalMembers,
        ),
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.borrowPendingBannerText,
        ),
      ),
    );
  }
}
