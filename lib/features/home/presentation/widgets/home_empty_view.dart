import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';

/// Full-screen empty state shown when the user has no projects yet.
class HomeEmptyView extends StatelessWidget {
  final VoidCallback onCreateProject;

  const HomeEmptyView({super.key, required this.onCreateProject});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.appBackgroundGradient,
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Bell icon top-right
            Padding(
              padding: EdgeInsets.only(top: 8.h, right: 20.w),
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  width: 38.w,
                  height: 38.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.notifications_outlined,
                      size: 20.w, color: AppColors.primary),
                ),
              ),
            ),

            const Spacer(),

            // Illustration
            SvgPicture.asset(
              AppAssets.homeEmptyState,
              width: 220.w,
              height: 220.w,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 28.h),

            // Title
            Text(
              AppStrings.homeEmptyTitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),

            // Subtitle
            Text(
              AppStrings.homeEmptySubtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13.5.sp,
                color: AppColors.textBody,
                height: 1.5,
              ),
            ),
            SizedBox(height: 32.h),

            // CTA button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.w),
              child: SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: onCreateProject,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100.r),
                    ),
                  ),
                  child: Text(
                    AppStrings.btnCreateProject,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}
