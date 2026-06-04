import 'package:flutter/material.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_svg_icon.dart';

/// Gradient disc + person/plus motif (project detail “No Members” empty state).
class ProjectMembersEmptyIllustration extends StatelessWidget {
  const ProjectMembersEmptyIllustration({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    const base = 120.0;
    final personSize = size * 52 / base;
    final badgeSize = size * 28 / base;
    final plusSize = size * 14 / base;
    final badgeInset = size * 18 / base;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.purple200, AppColors.purple500],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.purple600.withValues(alpha: 0.22),
                  blurRadius: size * 20 / base,
                  offset: Offset(0, size * 10 / base),
                ),
              ],
            ),
          ),
          AppSvgIcon(
            assetPath: AppAssets.iconPerson,
            size: personSize,
            color: AppColors.surface,
          ),
          Positioned(
            right: badgeInset,
            bottom: badgeInset,
            child: Container(
              width: badgeSize,
              height: badgeSize,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: AppSvgIcon(
                  assetPath: AppAssets.plusSign,
                  size: plusSize,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
