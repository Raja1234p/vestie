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

  const AppOutlineNeutralButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.borderRadius,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = borderRadius ?? 999.r;
    final border = borderColor ?? AppColors.neutral1200;
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          width: double.infinity,
          height: 56.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: border, width: 1.5.w),
          ),
          child: AppText(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral1200,
            ),
          ),
        ),
      ),
    );
  }
}
