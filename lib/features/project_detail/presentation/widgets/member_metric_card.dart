import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/text/app_text.dart';

class MemberMetricCard extends StatelessWidget {
  final String label;
  final String value;

  const MemberMetricCard({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 12.sp,
                  color: AppColors.grey900,
                ),
          ),
          SizedBox(height: 2.h),
          AppText(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.grey1100,
                ),
          ),
        ],
      ),
    );
  }
}
