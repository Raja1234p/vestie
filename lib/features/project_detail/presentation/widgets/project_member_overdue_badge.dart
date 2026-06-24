import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/theme/app_text_styles.dart';
import 'package:vestie/core/widgets/text/app_text.dart';

/// Overdue pill on project member rows — Figma Action/Error (text + amount only).
class ProjectMemberOverdueBadge extends StatelessWidget {
  final double amount;

  const ProjectMemberOverdueBadge({super.key, required this.amount});

  static const double _borderWidth = 0.5;

  @override
  Widget build(BuildContext context) {
    final outerRadius = BorderRadius.circular(100.r);
    final innerRadius = BorderRadius.circular(100.r - _borderWidth);
    final label = AppStrings.projectMemberOverdueBadgeLabel(amount);

    return Container(
      decoration: BoxDecoration(
        borderRadius: outerRadius,
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.actionErrorBorderLight,
            AppColors.actionErrorBorderDark,
          ],
        ),
      ),
      padding: const EdgeInsets.all(_borderWidth),
      child: ClipRRect(
        borderRadius: innerRadius,
        child: Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.actionErrorPressed,
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.actionErrorInnerShadow.withValues(alpha: 0.2),
                      AppColors.actionErrorInnerShadow.withValues(alpha: 0),
                    ],
                    stops: const [0.0, 0.55],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: ColoredBox(
                color: AppColors.neutral1200.withValues(alpha: 0.2),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimens.p8,
                vertical: 3.h,
              ),
              child: AppText(
                label,
                style: AppTextStyles.labelLarge.copyWith(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.surface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
