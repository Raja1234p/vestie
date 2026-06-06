import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';

enum SocialProvider { google, apple }

/// Social auth button using the real Figma brand SVG icons.
/// White card, 12px corners, #DDD0FC border ([AppColors.authSocialBorder]).
class SocialAuthButton extends StatelessWidget {
  final SocialProvider provider;
  final VoidCallback? onPressed;
  final bool isLoading;

  const SocialAuthButton({
    super.key,
    required this.provider,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null || isLoading;

    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: BorderSide(color: AppColors.authSocialBorder, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 0,
          disabledBackgroundColor: Colors.white,
          disabledForegroundColor: AppColors.authSocialText,
        ),
        child: isLoading
            ? SizedBox(
                width: 22.w,
                height: 22.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: isEnabled
                      ? AppColors.primary
                      : AppColors.authSocialText,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    provider == SocialProvider.google
                        ? AppAssets.authGoogle
                        : AppAssets.authApple,
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
