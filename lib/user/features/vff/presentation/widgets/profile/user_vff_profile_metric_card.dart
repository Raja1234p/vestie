import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/text/app_text.dart';

/// Contributions / Projects stat tile — fill `#F8F7FA`.
final class UserVffProfileMetricCard extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  const UserVffProfileMetricCard({
    super.key,
    required this.label,
    required this.value,
    this.labelStyle,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.vffProfileMetricCardBg,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.grey300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              label,
              style: labelStyle ??
                  GoogleFonts.lato(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.neutral1200,
                  ),
            ),
            SizedBox(height: 8.h),
            AppText(
              value,
              style: valueStyle ??
                  GoogleFonts.lato(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral1200,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
