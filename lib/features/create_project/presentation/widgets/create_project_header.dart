import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';

/// Gradient header shared across all create-project steps.
/// Shows "← Title" on the left and an optional step badge on the right.
class CreateProjectHeader extends StatelessWidget {
  final String title;
  final String? stepBadge;   // e.g. "1/3"
  final Color badgeColor;
  final VoidCallback? onBack;

  const CreateProjectHeader({
    super.key,
    required this.title,
    this.stepBadge,
    this.badgeColor = Colors.white,
    this.onBack,
  });

  /// Returns legible text color against a given badge background.
  Color _badgeTextColor() {
    // Light colors (white, light green, etc.) → dark text
    final lum = badgeColor.computeLuminance();
    return lum > 0.4 ? AppColors.textPrimary : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 52.h, 20.w, 20.h),
      decoration: const BoxDecoration(
        gradient: AppColors.appBackgroundGradient,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack ?? () => Navigator.of(context).pop(),
            child: Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  size: 20.w, color: AppColors.textPrimary),
            ),
          ),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          if (stepBadge != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(100.r),
                // Subtle border so white badge is visible on the lavender gradient
                border: badgeColor == Colors.white
                    ? Border.all(color: AppColors.purple300, width: 1)
                    : null,
              ),
              child: Text(
                stepBadge!,
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: _badgeTextColor(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
