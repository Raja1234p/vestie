import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_assets.dart';
import '../../theme/app_colors.dart';
import '../text/app_text.dart';
import 'app_button.dart';

/// A globally reusable full-page success screen.
class AppSuccessScreen extends StatelessWidget {
  final String? svgAssetPath;
  final String? backgroundImagePath;
  final String title;
  final String? subtitle;
  final Widget? subtitleWidget;
  final Widget? customContent;
  final Widget? bottomContent;
  final String buttonText;
  final VoidCallback onButtonPressed;

  const AppSuccessScreen({
    super.key,
    this.svgAssetPath,
    this.backgroundImagePath=AppAssets.contributionSuccessBg,
    required this.title,
    this.subtitle,
    this.subtitleWidget,
    this.customContent,
    this.bottomContent,
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
          image:  DecorationImage(
                image: AssetImage(backgroundImagePath!),
                fit: BoxFit.cover,
              )
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // ── Illustration ─────────────────────────────────
                if (svgAssetPath != null)
                  Image.asset(
                    svgAssetPath!,
                    width: 150.w,
                    height: 150.w,
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
                SizedBox(height: 10.h),

                ?subtitleWidget,
                if (subtitleWidget == null && subtitle != null)
                  AppText(
                    subtitle!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 18.sp,
                      color: AppColors.textBody,
                    ),
                  ),

                SizedBox(height: 20.h),

                // ── Custom Content (e.g. Share Links) ─────────────
                ?customContent,

                const Spacer(flex: 3),

                // ── Bottom Content (screen-specific footer actions) ─
                ?bottomContent,
                if (bottomContent != null) SizedBox(height: 12.h),

                // ── Action Button ─────────────────────────────────
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0.w, 0.h, 0.w, 20.h),
                    child: AppButton(
                      text: buttonText,
                      color: Colors.black,
                      useGradient: false,
                      hasShadow: false,
                      borderRadius: 8.r,
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
