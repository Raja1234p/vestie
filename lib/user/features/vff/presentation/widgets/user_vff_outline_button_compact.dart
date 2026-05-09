import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/text/app_text.dart';

/// Thin black-bordered pill (storyboard Decline / secondary actions).
class UserVffOutlineButtonCompact extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final double? height;

  const UserVffOutlineButtonCompact({
    super.key,
    required this.label,
    required this.onTap,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final h = height ?? 48.h;
    return SizedBox(
      height: h,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(color: AppColors.grey1100, width: 1.2.w),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(999.r),
          child: InkWell(
            borderRadius: BorderRadius.circular(999.r),
            onTap: onTap,
            child: Center(
              child: AppText(
                label,
                style: GoogleFonts.lato(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.grey1100,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
