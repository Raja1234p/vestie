import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/app_success_screen.dart';
import '../widgets/auth_gradient_button.dart';

/// After forgot-password flow completes — matches Figma "Password Updated".
/// Uses [AppSuccessScreen] (no AuthBackground — auth background is only for
/// login/register/forgot/verify/set-new-password forms).
class PasswordUpdatedSuccessScreen extends StatelessWidget {
  const PasswordUpdatedSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSuccessScreen(
      useAuthGradientBackground: true,
      backgroundImagePath: null,
      svgAssetPath: AppAssets.projectCreatedImage,
      title: AppStrings.passwordUpdatedTitle,
      subtitleWidget: Text(
        AppStrings.passwordUpdatedSubtitle,
        textAlign: TextAlign.center,
        style: GoogleFonts.lato(
          fontSize: 20.sp,
          fontWeight: FontWeight.w400,
          color: AppColors.authSubtitle,
          height: 1.3,
        ),
      ),
      footer: Padding(
        padding: EdgeInsets.only(bottom: 20.h),
        child: AuthGradientButton(
          text: AppStrings.btnBackToLogin,
          onPressed: () => context.go(AppRoutes.login),
          borderRadius: 12,
        ),
      ),
      buttonText: null,
      onButtonPressed: null,
    );
  }
}
