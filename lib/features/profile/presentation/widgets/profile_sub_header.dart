import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';

/// Reusable gradient header for profile sub-screens (← Title).
class ProfileSubHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;

  const ProfileSubHeader({
    super.key,
    required this.title,
    this.onBack,
    this.trailing,
  });

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
          ?trailing,
        ],
      ),
    );
  }
}
