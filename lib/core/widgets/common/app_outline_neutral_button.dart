import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/app_colors.dart';
import '../text/app_text.dart';

/// Full-width pill button: white fill, dark border (secondary actions, “No”, “Back”, etc.).
class AppOutlineNeutralButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final double? borderRadius;

  /// When null, uses [AppColors.neutral1200].
  final Color? borderColor;

  /// When null, uses [AppColors.surface].
  final Color? backgroundColor;
  final Widget? leading;

  /// When null, uses [AppColors.neutral1200] for the label.
  final Color? labelColor;
  final bool isLoading;

  /// No fill or stroke — label only (e.g. Leave Project screen Cancel).
  final bool borderless;

  /// Button height; defaults to 56.h.
  final double? height;

  const AppOutlineNeutralButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.borderRadius,
    this.borderColor,
    this.backgroundColor,
    this.leading,
    this.labelColor,
    this.isLoading = false,
    this.borderless = false,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = borderRadius ?? 999.r;
    final border = borderless
        ? Colors.transparent
        : (borderColor ?? AppColors.neutral1200);
    final textColor = labelColor ?? AppColors.neutral1200;
    return Material(
      color: borderless
          ? Colors.transparent
          : (backgroundColor ?? AppColors.surface),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: borderless
            ? BorderSide.none
            : BorderSide(color: border, width: 1.5.w),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          width: double.infinity,
          height: height ?? 56.h,
          alignment: Alignment.center,
          child: isLoading
              ? SizedBox(
                  width: 22.w,
                  height: 22.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: textColor,
                  ),
                )
              : leading == null
              ? AppText(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    leading!,
                    SizedBox(width: 8.w),
                    AppText(
                      label,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
