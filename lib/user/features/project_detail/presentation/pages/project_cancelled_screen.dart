import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_outline_neutral_button.dart';
import 'package:vestie/core/widgets/text/app_text.dart';

class ProjectCancelledScreen extends StatelessWidget {
  final String projectName;

  const ProjectCancelledScreen({
    super.key,
    required this.projectName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SafeArea(
              bottom: false,
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 24.h),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: AppColors.grey700),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          AppAssets.failureIcon,
                          height: 140.h,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: 24.h),
                        AppText(
                          AppStrings.projectCancelledTitle,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.grey1100,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        AppText(
                          AppStrings.projectCancelledDescription(projectName),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                            color: AppColors.grey900,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        AppText(
                          AppStrings.defaultedNoRefundShort,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                            color: AppColors.red900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            minimum: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
            child: AppOutlineNeutralButton(
              label: AppStrings.btnBackToHome,
              onPressed: () => context.go(AppRoutes.dashboard),
              borderRadius: AppRadius.r8,
              borderColor: AppColors.backToHomeButtonBorder,
            ),
          ),
        ],
      ),
    );
  }
}
