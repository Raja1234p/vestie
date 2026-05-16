import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/text/app_text.dart';

/// Pale red “Leave Project” CTA on the leave warning screen (Figma).
class LeaveProjectDestructiveButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const LeaveProjectDestructiveButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: AppColors.red200,
      borderRadius: BorderRadius.circular(AppRadius.r8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.r8),
        child: SizedBox(
          width: double.infinity,
          height: 56.h,
          child: Center(
            child: AppText(
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
    );
  }
}
