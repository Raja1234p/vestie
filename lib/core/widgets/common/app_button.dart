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
  final double? width;
  final double? height;
  final Color? color;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.hasShadow = false,
    this.width,
    this.height,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null;
    final theme = Theme.of(context);

    // Default primary gradient
    final gradient = isEnabled && !isSecondary
        ? const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.purple700, AppColors.purple900],
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
          borderRadius: BorderRadius.circular(999.r),
          border: isSecondary
              ? Border.all(color: AppColors.primary, width: 1.5.w)
              : Border.all(
                  color: isEnabled
                      ? AppColors.purple500.withValues(alpha: 0.45)
                      : AppColors.grey400,
                  width: 1.w,
                ),
          boxShadow: isEnabled && hasShadow ? AppShadows.primaryButton : null,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(999.r),
          child: InkWell(
            borderRadius: BorderRadius.circular(999.r),
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
                        fontWeight: FontWeight.w700,
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
