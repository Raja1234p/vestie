import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_svg_icon.dart';
import 'package:vestie/core/widgets/text/app_text.dart';

/// Figma empty members — gradient disc + person/plus motif.
class ProjectMembersEmptyState extends StatelessWidget {
  /// Full-screen list — vertically centered under the header.
  final bool centered;
  /// Tab preview with "View All" above — less top inset.
  final bool compactTop;

  const ProjectMembersEmptyState({
    super.key,
    this.centered = false,
    this.compactTop = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
            width: 120.w,
            height: 120.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 120.w,
                  height: 120.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.purple200, AppColors.purple500],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.purple600.withValues(alpha: 0.22),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                ),
                AppSvgIcon(
                  assetPath: AppAssets.iconPerson,
                  size: 52.w,
                  color: AppColors.surface,
                ),
                Positioned(
                  right: 18.w,
                  bottom: 18.w,
                  child: Container(
                    width: 28.w,
                    height: 28.w,
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: AppSvgIcon(
                        assetPath: AppAssets.plusSign,
                        size: 14.w,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          AppText(
            AppStrings.userInvestmentMembersEmpty,
            style: GoogleFonts.lato(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.neutral1200,
            ),
          ),
      ],
    );

    if (centered) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: content,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24.w,
        compactTop ? 16.h : 32.h,
        24.w,
        compactTop ? 32.h : 48.h,
      ),
      child: content,
    );
  }
}
