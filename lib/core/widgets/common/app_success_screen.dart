import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_assets.dart';
import '../../theme/app_colors.dart';
import '../text/app_text.dart';
import 'app_button.dart';
import 'flow_screen_footer.dart';

/// A globally reusable full-page success screen.
///
/// Uses [AppAssets.authGradientBg] and [AppAssets.projectCreatedImage] for all flows.
/// Bottom action uses 16.w horizontal / 24.h bottom inset (borrow terms footer).
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

  const AppSuccessScreen({
    super.key,
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

    final Widget actionChild = footer ??
        AppButton(
          text: buttonText!,
          color: AppColors.cardActionBtn,
          useGradient: false,
          hasShadow: false,
          borderRadius: 8.r,
          onPressed: onButtonPressed!,
        );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              AppAssets.authGradientBg,
              fit: BoxFit.fill,
            ),
          ),
          Column(
            children: [
              Expanded(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Center(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _SuccessIllustration(
                              path: AppAssets.projectCreatedImage,
                            ),
                            AppText(
                              title,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    fontSize: 26.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
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
    return Image.asset(
      path,
      width: s,
      height: s,
      fit: BoxFit.contain,
    );
  }
}
