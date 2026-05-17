import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/text/app_text.dart';

/// Pale red “Leave Project” CTA on the leave warning screen (Figma).
class LeaveProjectDestructiveButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const LeaveProjectDestructiveButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: AppColors.red200,
      borderRadius: BorderRadius.circular(AppRadius.r8),
      child: IgnorePointer(
        ignoring: isLoading,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadius.r8),
          splashColor: AppColors.red900.withValues(alpha: 0.12),
          highlightColor: AppColors.red900.withValues(alpha: 0.08),
          child: SizedBox(
            width: double.infinity,
            height: 56.h,
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 24.w,
                      height: 24.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.red900,
                      ),
                    )
                  : AppText(
                      label,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.red900,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
