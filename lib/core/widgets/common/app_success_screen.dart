import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    this.backgroundImagePath = AppAssets.contributionSuccessBg,
    required this.title,
    this.subtitle,
    this.subtitleWidget,
    this.customContent,
    this.bottomContent,
    required this.buttonText,
    required this.onButtonPressed,
  })  : assert(
          svgAssetPath != null || backgroundImagePath != null,
          'Either svgAssetPath or backgroundImagePath must be provided',
        );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (backgroundImagePath != null)
            Positioned.fill(
              child: Image.asset(
                backgroundImagePath!,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            )
          else
            Positioned.fill(
              child: ColoredBox(color: AppColors.purple200),
            ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  if (svgAssetPath != null) ...[
                    _SuccessIllustration(path: svgAssetPath!),
                    SizedBox(height: 24.h),
                  ],

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

                  ?customContent,

                  const Spacer(flex: 3),

                  ?bottomContent,
                  if (bottomContent != null) SizedBox(height: 12.h),

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
    // Figma hero art (e.g. “successful” badge) is typically 174×174 logical.
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
