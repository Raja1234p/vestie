import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/app_colors.dart';
import '../text/app_text.dart';

class AppInfoNotice extends StatelessWidget {
  final String text;

  const AppInfoNotice({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.blue100,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 20.w,
            color: AppColors.blue900,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: AppText(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 15.sp,
                    color: AppColors.blue900,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
