import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/common/post_auth_header.dart';
import 'package:vestie/core/widgets/text/app_text.dart';

import '../models/user_investment_ui_snapshot.dart';

/// Heavy warning before finalizing leave (destructive affordance).
class UserLeaveProjectWarningScreen extends StatelessWidget {
  final UserInvestmentUiSnapshot snapshot;

  const UserLeaveProjectWarningScreen({super.key, required this.snapshot});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PostAuthGradientBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PostAuthHeader(
                title: snapshot.projectName,
                leading: AppBackButton(onPressed: () => context.pop()),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    children: [
                      SizedBox(height: 12.h),
                      Image.asset(
                        AppAssets.failureIcon,
                        width: 96.w,
                        height: 96.w,
                      ),
                      SizedBox(height: 20.h),
                      AppText(
                        AppStrings.userLeaveWarningTitle,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 14.h),
                      AppText(
                        AppStrings.userLeaveWarningBody,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(
                          fontSize: 13.sp,
                          height: 1.45,
                          color: AppColors.textBody,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextButton(
                      onPressed: () => context.pushReplacement(
                        AppRoutes.userInvestmentLeaveSuccess,
                      ),
                      child: AppText(
                        AppStrings.userLeaveConfirmLeave,
                        style: GoogleFonts.lato(
                          fontWeight: FontWeight.w900,
                          fontSize: 16.sp,
                          color: AppColors.error,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    AppButton(
                      text: AppStrings.btnCancel,
                      isSecondary: true,
                      onPressed: () => context.pop(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
