import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/theme/app_text_styles.dart';
import 'package:vestie/core/widgets/common/app_svg_icon.dart';
import 'package:vestie/core/widgets/text/app_text.dart';

/// Co-leader pill on project member rows — Figma Action/Success/Pressed.
class ProjectMemberCoLeaderBadge extends StatelessWidget {
  const ProjectMemberCoLeaderBadge({super.key});

  static const double _borderWidth = 0.5;

  @override
  Widget build(BuildContext context) {
    final outerRadius = BorderRadius.circular(100.r);
    final innerRadius = BorderRadius.circular(100.r - _borderWidth);

    return Container(
      decoration: BoxDecoration(
        borderRadius: outerRadius,
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.actionSuccessBorderLight,
            AppColors.actionSuccessBorderDark,
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
                  color: AppColors.actionSuccessPressed,
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
                      AppColors.actionSuccessInnerShadow.withValues(alpha: 0.5),
                      AppColors.actionSuccessInnerShadow.withValues(alpha: 0),
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppSvgIcon(
                    assetPath: AppAssets.iconCoLeaderUsers,
                    size: 12.w,
                    color: AppColors.surface,
                  ),
                  SizedBox(width: AppDimens.p4),
                  AppText(
                    AppStrings.projectMemberCoLeaderBadge,
                    style: AppTextStyles.labelLarge.copyWith(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.surface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
