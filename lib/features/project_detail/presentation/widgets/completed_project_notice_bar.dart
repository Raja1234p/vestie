import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/app_svg_icon.dart';
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

  static double get _iconSize => 20.w;

  static double get _iconGap => 8.w;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontSize: 17.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.projectDetailText,
        );
    final bodyStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          height: 1.45,
          color: AppColors.projectDetailText,
        );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.purple200.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppSvgIcon(
                assetPath: AppAssets.iconInfo,
                size: _iconSize,
                color: AppColors.grey800,
              ),
              SizedBox(width: _iconGap),
              Expanded(
                child: AppText(
                  title,
                  style: titleStyle,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Padding(
            padding: EdgeInsets.only(left: _iconSize + _iconGap),
            child: AppText(
              body,
              style: bodyStyle,
            ),
          ),
        ],
      ),
    );
  }
}
