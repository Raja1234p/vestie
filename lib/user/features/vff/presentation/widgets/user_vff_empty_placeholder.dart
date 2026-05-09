import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_svg_icon.dart';
import 'package:vestie/core/widgets/text/app_text.dart';

/// Large gradient disc + person/plus motif (VFF empty states).
class UserVffEmptyPlaceholder extends StatelessWidget {
  final String message;

  const UserVffEmptyPlaceholder({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 48.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 168.w,
            height: 168.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.purple200,
                  AppColors.purple400,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.purple600.withValues(alpha: 0.25),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: AppSvgIcon(
              assetPath: AppAssets.plusSign,
              size: 72.r,
              color: AppColors.surface,
            ),
          ),
          SizedBox(height: 28.h),
          AppText(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textBody,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
