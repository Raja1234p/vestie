import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_shadows.dart';
import '../text/app_text.dart';

/// Full-width call-to-action used across auth, onboarding, and flows like create-project.
///
/// **Defaults:** purple vertical gradient, light edge stroke, drop shadow, pill shape
/// (`borderRadius` ~999.r), label **18.sp / w500** (white on primary, purple on secondary).
///
/// Override when needed: [isSecondary] (outline), [useGradient] + [color] (flat fill),
/// [hasShadow], [borderRadius], [isLoading], [leading].
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
  /// Stroke on flat primary buttons ([useGradient] false).
  final Color? borderColor;
  final Color? secondaryBorderColor;
  final Color? secondaryLabelColor;
  final FontWeight? secondaryLabelFontWeight;
  /// Label size; defaults to 18.sp.
  final double? labelFontSize;
  /// Outline button fill (e.g. white on gradient backgrounds).
  final Color? secondaryFillColor;
  final Widget? leading;

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
    this.borderColor,
    this.secondaryBorderColor,
    this.secondaryLabelColor,
    this.secondaryLabelFontWeight,
    this.labelFontSize,
    this.secondaryFillColor,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null;
    /// Keep fill/border while [isLoading] — disabled styling only when truly inactive.
    final bool useActiveStyle = isEnabled || isLoading;
    final bool showPrimaryShadow =
        useActiveStyle && hasShadow && !isSecondary && useGradient;
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(borderRadius ?? 999.r);

    // Default primary gradient
    final gradient = useActiveStyle && !isSecondary && useGradient
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
          color: useActiveStyle
              ? (isSecondary
                  ? (secondaryFillColor ?? Colors.transparent)
                  : (gradient == null ? (color ?? AppColors.primary) : null))
              : AppColors.textHint,
          borderRadius: radius,
          border: isSecondary
              ? Border.all(
                  color: secondaryBorderColor ?? AppColors.primary,
                  width: 1.w,
                )
              : !useActiveStyle
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
                          color: borderColor ?? Colors.transparent,
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
                  : _labelRow(
                      context: context,
                      theme: theme,
                      isSecondary: isSecondary,
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _labelRow({
    required BuildContext context,
    required ThemeData theme,
    required bool isSecondary,
  }) {
    final style = theme.textTheme.labelLarge?.copyWith(
      fontSize: labelFontSize ?? 18.sp,
      fontWeight: isSecondary
          ? (secondaryLabelFontWeight ?? FontWeight.w500)
          : FontWeight.w500,
      color: isSecondary
          ? (secondaryLabelColor ?? AppColors.primary)
          : AppColors.surface,
    );
    final label = AppText(
      text,
      style: style,
    );
    if (leading == null) {
      return label;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        leading!,
        SizedBox(width: 8.w),
        label,
      ],
    );
  }
}
