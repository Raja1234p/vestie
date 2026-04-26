import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/text/app_text.dart';

/// Informational callout: closed project, no further contributions.
/// Content comes from the caller (e.g. [CompletedProjectNoticeCopy]).
class CompletedProjectNoticeBar extends StatelessWidget {
  final String title;
  final String body;

  const CompletedProjectNoticeBar({
    super.key,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.purple200.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 20.w,
            color: AppColors.grey800,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.grey900,
                      ),
                ),
                SizedBox(height: 4.h),
                AppText(
                  body,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        height: 1.45,
                        color: AppColors.grey900,
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
