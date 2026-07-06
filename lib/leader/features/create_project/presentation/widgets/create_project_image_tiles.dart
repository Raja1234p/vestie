import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/leader/features/create_project/presentation/create_project_image_tile_style.dart';

/// Selected project image tile — 114×114, radius 12, delete affordance.
class CreateProjectImageTile extends StatelessWidget {
  final String imagePath;
  final VoidCallback onRemove;

  const CreateProjectImageTile({
    super.key,
    required this.imagePath,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final radius = CreateProjectImageTileStyle.tileRadius.r;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth;

        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: Image.file(
                  File(imagePath),
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 6.h,
                right: 6.w,
                child: GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    width: 24.w,
                    height: 24.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4.r,
                          offset: Offset(0, 1.h),
                        ),
                      ],
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        AppAssets.iconDelete,
                        width: 14.w,
                        height: 14.w,
                        colorFilter: const ColorFilter.mode(
                          AppColors.red900,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Add-more tile — shown until [maxImages] reached (Figma).
class CreateProjectUploadImageTile extends StatelessWidget {
  final VoidCallback onTap;

  const CreateProjectUploadImageTile({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final radius = CreateProjectImageTileStyle.tileRadius.r;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth;

        return GestureDetector(
          onTap: onTap,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(radius),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  AppAssets.iconAddImage,
                  width: 32.w,
                  height: 32.w,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 8.h),
                AppText(
                  AppStrings.createProjectUploadImageTileLabel,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral1200,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
