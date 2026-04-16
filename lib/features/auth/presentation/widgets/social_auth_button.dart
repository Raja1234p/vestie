import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';

enum SocialProvider { google, apple }

/// Social auth button using the real Figma brand SVG icons.
/// White outlined pill — matches Login/Register Figma screens exactly.
class SocialAuthButton extends StatelessWidget {
  final SocialProvider provider;
  final VoidCallback onPressed;

  const SocialAuthButton({
    super.key,
    required this.provider,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: BorderSide(color: AppColors.authSocialBorder, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100.r),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Real SVG icon from assets ──────────────────────────
            SvgPicture.asset(
              provider == SocialProvider.google
                  ? AppAssets.iconGoogle
                  : AppAssets.iconApple,
              width: 20.w,
              height: 20.h,
              fit: BoxFit.contain,
            ),
            SizedBox(width: 10.w),
            Text(
              provider == SocialProvider.google
                  ? AppStrings.btnGoogle
                  : AppStrings.btnApple,
              style: GoogleFonts.lato(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.authSocialText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
