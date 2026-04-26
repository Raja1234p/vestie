import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/app_colors.dart';
import '../text/app_text.dart';

/// Muted warning strip (e.g. defaulted / no refund) — reusable across flows.
class AppDestructiveNoticeBar extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;

  const AppDestructiveNoticeBar({
    super.key,
    required this.text,
    this.backgroundColor = AppColors.red100,
    this.textColor = AppColors.red900,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: AppText(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: textColor,
              height: 1.4,
            ),
      ),
    );
  }
}
