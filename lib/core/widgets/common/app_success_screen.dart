import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../constants/app_assets.dart';
import '../../theme/app_colors.dart';
import '../text/app_text.dart';
import 'app_button.dart';

/// A globally reusable full-page success screen.
///
/// Background: always uses [AppAssets.authGradientBg] (purple-to-white PNG)
/// with white scaffold colour — consistent across auth and app-wide success
/// screens. The [backgroundImagePath] and [useAuthGradientBackground] params
/// are kept for backward-compat but both now resolve to the same gradient PNG.
class AppSuccessScreen extends StatelessWidget {
  final String? svgAssetPath;
  // kept for API compat — ignored; gradient PNG is always used instead
  final String? backgroundImagePath;
  final bool useAuthGradientBackground;
  final String title;
  final String? subtitle;
  final Widget? subtitleWidget;
  final Widget? customContent;
  final Widget? bottomContent;
  /// Replaces the default bottom [AppButton] when non-null.
  final Widget? footer;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const AppSuccessScreen({
    super.key,
    this.svgAssetPath,
    this.backgroundImagePath = AppAssets.contributionSuccessBg,
    this.useAuthGradientBackground = false,
    required this.title,
    this.subtitle,
    this.subtitleWidget,
    this.customContent,
    this.bottomContent,
    this.footer,
    this.buttonText,
    this.onButtonPressed,
  }) : assert(
          footer != null || (buttonText != null && onButtonPressed != null),
          'Provide footer or both buttonText and onButtonPressed.',
        );

  @override
  Widget build(BuildContext context) {
    final Widget? resolvedSubtitle = subtitleWidget ??
        (subtitle != null
            ? AppText(
                subtitle!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF5E5783),
                    ),
              )
            : null);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Auth gradient PNG — shared background for all success screens
          Positioned.fill(
            child: Image.asset(
              AppAssets.authGradientBg,
              fit: BoxFit.fill,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  if (svgAssetPath != null) ...[
                    _SuccessIllustration(path: svgAssetPath!),
                  ],
                  AppText(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),
                  if (resolvedSubtitle != null) ...[
                    resolvedSubtitle,
                    SizedBox(height: 20.h),
                  ] else
                    SizedBox(height: 20.h),
                  if (customContent case final c?) ...[c],
                  const Spacer(flex: 3),
                  if (bottomContent case final b?) ...[
                    b,
                    SizedBox(height: 12.h),
                  ],
                  if (footer != null)
                    SafeArea(
                      top: false,
                      child: footer!,
                    )
                  else
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(0.w, 0.h, 0.w, 20.h),
                        child: AppButton(
                          text: buttonText!,
                          color: AppColors.cardActionBtn,
                          useGradient: false,
                          hasShadow: false,
                          borderRadius: 8.r,
                          onPressed: onButtonPressed!,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessIllustration extends StatelessWidget {
  const _SuccessIllustration({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    final s = 174.w;
    if (path.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        path,
        width: s,
        height: s,
        fit: BoxFit.contain,
      );
    }
    return Image.asset(
      path,
      width: s,
      height: s,
      fit: BoxFit.contain,
    );
  }
}
