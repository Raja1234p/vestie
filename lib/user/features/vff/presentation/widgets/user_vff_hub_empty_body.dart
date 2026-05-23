import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/text/app_text.dart';

/// VFF hub empty state — parent must be [Expanded] so this column can center.
class UserVffHubEmptyBody extends StatelessWidget {
  final String message;
  final String? subtitle;

  const UserVffHubEmptyBody({
    super.key,
    required this.message,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          AppAssets.borrowRequestsEmptyState,
          width: 100.w,
          height: 100.h,
          fit: BoxFit.contain,
        ),
        SizedBox(height: 20.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              AppText(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.grey1100,
                  height: 1.35,
                ),
              ),
              if (subtitle != null) ...[
                SizedBox(height: 8.h),
                AppText(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textBody,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
