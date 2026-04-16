import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/app_text.dart';

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
      padding: EdgeInsets.fromLTRB(16.w, 70.h, 20.w, 20.h),

      child: Row(
        children: [
          GestureDetector(
            onTap: onBack ?? () => context.pop(),
            child: Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  size: 20.w, color: AppColors.textPrimary),
            ),
          ),
          AppText(
            title,
            style: GoogleFonts.lato(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
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
