import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/app_button.dart';

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
                child: GestureDetector(
                  onTap: () => context.push(AppRoutes.notifications),
                  child: Padding(
                    padding: EdgeInsets.all(4.w),
                    child: SvgPicture.asset(
                      AppAssets.iconNotification,
                      width: 24.w,
                      height: 24.w,
                      fit: BoxFit.contain,
                    ),
                  ),
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
              style: GoogleFonts.lato(
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
              style: GoogleFonts.lato(
                fontSize: 13.5.sp,
                color: AppColors.textBody,
                height: 1.5,
              ),
            ),
            SizedBox(height: 32.h),

            // CTA button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.w),
              child: AppButton(
                text: AppStrings.btnCreateProject,
                height: 48.h,
                onPressed: onCreateProject,
              ),
            ),

            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}
