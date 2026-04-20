import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/app_colors.dart';
import '../text/app_text.dart';
import 'app_button.dart';

/// A globally reusable full-page success screen.
class AppSuccessScreen extends StatelessWidget {
  final String? svgAssetPath;
  final String? backgroundImagePath;
  final String title;
  final Widget? customContent;
  final String buttonText;
  final VoidCallback onButtonPressed;

  const AppSuccessScreen({
    super.key,
    this.svgAssetPath,
    this.backgroundImagePath,
    required this.title,
    this.customContent,
    required this.buttonText,
    required this.onButtonPressed,
  }) : assert(svgAssetPath != null || backgroundImagePath != null, 
          'Either svgAssetPath or backgroundImagePath must be provided');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: backgroundImagePath == null ? AppColors.appBackgroundGradient : null,
          image: backgroundImagePath != null 
            ? DecorationImage(
                image: AssetImage(backgroundImagePath!),
                fit: BoxFit.cover,
              )
            : null,
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // ── Illustration ─────────────────────────────────
                if (svgAssetPath != null)
                  SvgPicture.asset(
                    svgAssetPath!,
                    width: 120.w,
                    height: 120.w,
                  ),
                
                if (svgAssetPath != null) SizedBox(height: 24.h),

                // ── Title ─────────────────────────────────────────
                AppText(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20.h),

                // ── Custom Content (e.g. Share Links) ─────────────
                if (customContent != null) customContent!,

                const Spacer(flex: 3),

                // ── Action Button ─────────────────────────────────
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0.w, 0.h, 0.w, 20.h),
                    child: AppButton(
                      text: buttonText,
                      onPressed: onButtonPressed,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
