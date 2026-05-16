import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/core/widgets/common/app_success_screen.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';

import '../models/create_project_status_screen_args.dart';

/// Success / failure status (`create_project_status_screen` storyboard parity).
class CreateProjectStatusScreen extends StatelessWidget {
  final CreateProjectStatusScreenArgs args;

  const CreateProjectStatusScreen({
    super.key,
    required this.args,
  });

  void _finish(BuildContext context) => context.go(AppRoutes.dashboard);

  @override
  Widget build(BuildContext context) {
    if (args.success) {
      return AppSuccessScreen(
        title: AppStrings.transactionStatusSuccessTitle,
        subtitle: AppStrings.transactionStatusSuccessSubtitle,
        buttonText: AppStrings.btnDone,
        onButtonPressed: () => _finish(context),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PostAuthGradientBackground(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                SizedBox(height: 24.h),
                Image.asset(AppAssets.failureIcon, width: 120.w, height: 120.w),
                SizedBox(height: 28.h),
                Text(
                  AppStrings.transactionStatusFailureTitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  AppStrings.transactionStatusFailureSubtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    fontSize: 13.sp,
                    height: 1.45,
                    color: AppColors.textBody,
                  ),
                ),
                const Spacer(),
                AppButton(
                  text: AppStrings.btnRetry,
                  onPressed: () => context.pop(),
                ),
                SizedBox(height: 12.h),
                AppButton(
                  text: AppStrings.btnCancel,
                  isSecondary: true,
                  onPressed: () => _finish(context),
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
