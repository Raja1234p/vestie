import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';

/// Auth flows — back chevron + “Go Back” (forgot password, reset password, OTP).
class AuthGoBackButton extends StatelessWidget {
  const AuthGoBackButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final iconSize = AppDimens.backIconSize;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final cachePx = math.max(1, (iconSize * dpr).round());

    return Semantics(
      button: true,
      label: AppStrings.btnGoBack,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              AppAssets.iconArrowBack,
              width: iconSize,
              height: iconSize,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.medium,
              cacheWidth: cachePx,
              cacheHeight: cachePx,
            ),
            SizedBox(width: 8.w),
            Text(
              AppStrings.btnGoBack,
              style: GoogleFonts.lato(
                fontSize: 26.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral1200,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
