import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/post_auth_header.dart';

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
    return PostAuthHeader(
      title: title,
      leading: GestureDetector(
        onTap: onBack ?? () => context.pop(),
        child: Icon(Icons.arrow_back,
            size: 24.w, color: AppColors.textPrimary),
      ),
      trailing: stepBadge == null
          ? null
          : Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(100.r),
                border: badgeColor == Colors.white
                    ? Border.all(color: AppColors.purple300, width: 1)
                    : null,
              ),
              child: Text(
                stepBadge!,
                style: GoogleFonts.lato(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: _badgeTextColor(),
                ),
              ),
            ),
    );
  }
}
