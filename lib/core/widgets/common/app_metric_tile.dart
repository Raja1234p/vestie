import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';
import '../text/app_text.dart';

/// Compact label + value tile (e.g. funds history summary row).
class AppMetricTile extends StatelessWidget {
  final String label;
  final String value;

  const AppMetricTile({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            label,
            style: GoogleFonts.lato(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.projectFundsMetricValue,
              height: 1.3,
            ),
          ),
          SizedBox(height: 4.h),
          AppText(
            value,
            style: GoogleFonts.lato(
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.projectFundsMetricValue,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
