/// Centralised snackbar system — Rule 5 & 6 compliance.
///
/// NEVER call ScaffoldMessenger or SnackBar directly.
/// Always use:
///   AppSnackBar.showSuccess(context, AppStrings.someMessage)
///   AppSnackBar.showError(context, AppStrings.someMessage)
///   AppSnackBar.showInfo(context, AppStrings.someMessage)
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_assets.dart';
import '../theme/app_colors.dart';
import '../widgets/common/app_svg_icon.dart';

class AppSnackBar {
  AppSnackBar._();

  static void showSuccess(BuildContext context, String message) {
    _show(
      context,
      message: message,
      backgroundColor: AppColors.validSuccess,
      iconAsset: AppAssets.checkMarkSuccessful,
    );
  }

  static void showError(BuildContext context, String message) {
    _show(
      context,
      message: message,
      backgroundColor: AppColors.error,
      iconAsset: AppAssets.iconClose,
    );
  }

  static void showInfo(BuildContext context, String message) {
    _show(
      context,
      message: message,
      backgroundColor: AppColors.primary,
      iconAsset: AppAssets.iconInfo,
    );
  }

  static void _show(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    required String iconAsset,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: backgroundColor,
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          duration: const Duration(seconds: 3),
          content: Row(
            children: [
              AppSvgIcon(
                assetPath: iconAsset,
                size: 18.w,
                color: Colors.white,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.lato(
                    fontSize: 13.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
