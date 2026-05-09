import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/text/app_text.dart';

/// Confirmation after leaving the investment project (mock finalize).
class UserLeaveProjectSuccessScreen extends StatelessWidget {
  const UserLeaveProjectSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PostAuthGradientBackground(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                SizedBox(height: 24.h),
                SvgPicture.asset(
                  AppAssets.checkMarkSuccessful,
                  width: 100.w,
                  height: 100.w,
                ),
                SizedBox(height: 24.h),
                AppText(
                  AppStrings.userLeaveSuccessfulTitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 10.h),
                AppText(
                  AppStrings.userLeaveSuccessfulSubtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    fontSize: 13.sp,
                    height: 1.45,
                    color: AppColors.textBody,
                  ),
                ),
                const Spacer(),
                AppButton(
                  text: AppStrings.userLeaveBrowseOther,
                  onPressed: () => context.go(AppRoutes.dashboard),
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
