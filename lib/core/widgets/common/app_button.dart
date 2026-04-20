import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_shadows.dart';
import '../text/app_text.dart';

/// Central Master Button for the application.
/// Supports Primary (Gradient), Secondary (Outline), Shadows, and Loading states.
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;
  final bool hasShadow;
  final bool useGradient;
  final double? borderRadius;
  final double? width;
  final double? height;
  final Color? color;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.hasShadow = true,
    this.useGradient = true,
    this.borderRadius,
    this.width,
    this.height,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null;
    final bool showPrimaryShadow = isEnabled && hasShadow && !isSecondary && useGradient;
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(borderRadius ?? 999.r);

    // Default primary gradient
    final gradient = isEnabled && !isSecondary && useGradient
        ? const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.purple600, AppColors.purple800, AppColors.purple700],
            stops: [0.0, 0.55, 1.0],
          )
        : null;

    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 56.h,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: gradient,
          color: isEnabled 
              ? (isSecondary ? Colors.transparent : (gradient == null ? (color ?? AppColors.primary) : null))
              : AppColors.textHint,
          borderRadius: radius,
          border: isSecondary
              ? Border.all(color: AppColors.primary, width: 1.5.w)
              : !isEnabled
                  ? Border.all(
                      color: AppColors.grey400,
                      width: 1.w,
                    )
                  : useGradient
                      ? Border.all(
                          color: AppColors.surface.withValues(alpha: 0.42),
                          width: 1.w,
                        )
                      : Border.all(
                          color: Colors.transparent,
                          width: 1.w,
                        ),
          boxShadow: showPrimaryShadow ? AppShadows.primaryButton : null,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: radius,
          child: InkWell(
            borderRadius: radius,
            onTap: (isLoading || !isEnabled) ? null : onPressed,
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 22.w,
                      height: 22.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: isSecondary ? AppColors.primary : AppColors.surface,
                      ),
                    )
                  : AppText(
                      text,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: isSecondary ? AppColors.primary : AppColors.surface,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
