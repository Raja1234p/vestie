import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_assets.dart';
import '../../constants/app_dimens.dart';
import '../../theme/app_colors.dart';
import '../text/app_text.dart';
import 'app_back_button.dart';
import 'app_button.dart';
import 'flow_screen_footer.dart';

/// A globally reusable full-page success screen.
///
/// Background: white + top [AppAssets.successScreenBackground] (Home / Discover style).
/// Bottom action uses [FlowScreenFooter] (20.w horizontal + system safe-area inset).
///
/// System back (Android) and predictive / swipe-back are disabled unless
/// [showBackButton] is true — otherwise user must tap the footer CTA to leave.
class AppSuccessScreen extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? subtitleWidget;
  final Widget? customContent;
  final Widget? bottomContent;

  /// Replaces the default bottom [AppButton] when non-null (still uses standard footer inset).
  final Widget? footer;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  /// Hero image above the title; defaults to [AppAssets.successProjectCreated].
  final String? illustrationAsset;

  /// When set, content aligns to the top with this gap below [SafeArea] before the hero image.
  final double? illustrationTopSpacing;

  /// Hero image size; defaults to 174.w.
  final double? illustrationSize;

  /// Tints the hero image (e.g. white on gradient header).
  final Color? illustrationColor;

  /// Title color; defaults to [AppColors.textPrimary].
  final Color? titleColor;

  /// When true, shows [AppBackButton] and allows system back (e.g. completed projects outcome).
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color? backButtonColor;
  final EdgeInsetsGeometry? backButtonPadding;
  final double? backButtonSize;

  const AppSuccessScreen({
    super.key,
    required this.title,
    this.titleColor,
    this.subtitle,
    this.subtitleWidget,
    this.customContent,
    this.bottomContent,
    this.footer,
    this.buttonText,
    this.onButtonPressed,
    this.illustrationAsset,
    this.illustrationTopSpacing,
    this.illustrationSize,
    this.illustrationColor,
    this.showBackButton = false,
    this.onBackPressed,
    this.backButtonColor,
    this.backButtonPadding,
    this.backButtonSize,
  }) : assert(
         footer != null || (buttonText != null && onButtonPressed != null),
         'Provide footer or both buttonText and onButtonPressed.',
       );

  @override
  Widget build(BuildContext context) {
    final Widget? resolvedSubtitle =
        subtitleWidget ??
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

    final Widget actionChild =
        footer ??
        AppButton(
          text: buttonText!,
          color: AppColors.cardActionBtn,
          useGradient: false,
          hasShadow: false,
          borderRadius: 8.r,
          onPressed: onButtonPressed!,
        );

    return PopScope(
      canPop: showBackButton,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          fit: StackFit.expand,
          children: [
            const _HomeEmptyStateBackground(),
            Column(
              children: [
                Expanded(
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: _SuccessScrollBody(
                        topSpacing: illustrationTopSpacing,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _SuccessIllustration(
                              path:
                                  illustrationAsset ??
                                  AppAssets.successProjectCreated,
                              size: illustrationSize,
                              color: illustrationColor,
                            ),
                            AppText(
                              title,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    fontSize: 26.sp,
                                    fontWeight: FontWeight.bold,
                                    color: titleColor ?? AppColors.textPrimary,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            if (resolvedSubtitle != null) ...[
                              SizedBox(height: 8.h),
                              resolvedSubtitle,
                            ],
                            if (customContent case final c?) ...[
                              SizedBox(height: 20.h),
                              c,
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (bottomContent case final b?) ...[
                  Padding(
                    padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 12.h),
                    child: b,
                  ),
                ],
                FlowScreenFooter(child: actionChild),
              ],
            ),
            if (showBackButton)
              SafeArea(
                child: Padding(
                  padding:
                      backButtonPadding ??
                      EdgeInsets.only(left: 8.w, top: 4.h),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: AppBackButton(
                      color: backButtonColor,
                      size: backButtonSize,
                      onPressed:
                          onBackPressed ?? () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// White screen + top [AppAssets.successScreenBackground] only (Home / Discover).
class _HomeEmptyStateBackground extends StatelessWidget {
  const _HomeEmptyStateBackground();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(child: ColoredBox(color: Colors.white)),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Image(
            image: AssetImage(AppAssets.successScreenBackground),
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }
}

class _SuccessScrollBody extends StatelessWidget {
  const _SuccessScrollBody({required this.child, this.topSpacing});

  final Widget child;
  final double? topSpacing;

  @override
  Widget build(BuildContext context) {
    final scrollView = SingleChildScrollView(
      padding: EdgeInsets.only(top: topSpacing ?? 16.h, bottom: 16.h),
      child: child,
    );

    if (topSpacing != null) {
      return Align(alignment: Alignment.topCenter, child: scrollView);
    }

    return Center(child: scrollView);
  }
}

class _SuccessIllustration extends StatelessWidget {
  const _SuccessIllustration({
    required this.path,
    this.size,
    this.color,
  });

  final String path;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final dimension = size ?? 174.w;
    Widget image;
    if (path == AppAssets.statusFailure) {
      image = Image.asset(
        path,
        width: size ?? AppDimens.failureIconWidth,
        height: size ?? AppDimens.failureIconHeight,
        fit: BoxFit.contain,
      );
    } else {
      image = Image.asset(
        path,
        width: dimension,
        height: dimension,
        fit: BoxFit.contain,
      );
    }

    if (color != null) {
      image = ColorFiltered(
        colorFilter: ColorFilter.mode(color!, BlendMode.srcIn),
        child: image,
      );
    }

    return image;
  }
}
