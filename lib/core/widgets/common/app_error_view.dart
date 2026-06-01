import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_assets.dart';
import '../../constants/app_strings.dart';
import '../../theme/app_colors.dart';
import 'app_button.dart';
import 'app_svg_icon.dart';

/// Full-view error state widget with an optional retry action.
class AppErrorView extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;

  const AppErrorView({super.key, this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppSvgIcon(
              assetPath: AppAssets.iconClose,
              size: 56.w,
              color: AppColors.error,
            ),
            SizedBox(height: 16.h),
            Text(
              message ?? AppStrings.errorGeneric,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            if (onRetry != null) ...[
              SizedBox(height: 24.h),
              AppButton(text: AppStrings.btnRetry, onPressed: onRetry),
            ],
          ],
        ),
      ),
    );
  }
}
