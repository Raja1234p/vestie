import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/leader/features/project_detail/presentation/announcement_image_preview_style.dart';

/// Optional single-image upload on create announcement (Figma).
class AnnouncementImageUploadField extends StatelessWidget {
  final String? imagePath;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  const AnnouncementImageUploadField({
    super.key,
    required this.imagePath,
    required this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
      fontSize: 15.sp,
      fontWeight: FontWeight.w500,
      color: AppColors.authLabel,
    );
    final radius = AnnouncementImagePreviewStyle.cornerRadius.r;
    final hasImage = imagePath != null && imagePath!.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppText(AppStrings.announcementUploadImageLabel, style: labelStyle),
        SizedBox(height: 12.h),
        if (hasImage)
          _SelectedImagePreview(
            imagePath: imagePath!,
            radius: radius,
            onRemove: onRemove,
            onReplace: onTap,
          )
        else
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(
                minHeight: AnnouncementImagePreviewStyle.emptyUploadMinHeight.h,
              ),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(color: AppColors.purple300, width: 1.w),
              ),
              child: const _EmptyUploadPrompt(),
            ),
          ),
      ],
    );
  }
}

class _EmptyUploadPrompt extends StatelessWidget {
  const _EmptyUploadPrompt();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 28.h, horizontal: 16.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            AppAssets.iconAddImage,
            width: 32.w,
            height: 32.w,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 10.h),
          AppText(
            AppStrings.createProjectUploadImageTileLabel,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral1200,
            ),
          ),
          SizedBox(height: 4.h),
          AppText(
            AppStrings.announcementUploadImageHint,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.grey700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedImagePreview extends StatelessWidget {
  final String imagePath;
  final double radius;
  final VoidCallback? onRemove;
  final VoidCallback onReplace;

  const _SelectedImagePreview({
    required this.imagePath,
    required this.radius,
    required this.onRemove,
    required this.onReplace,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AnnouncementImagePreviewStyle.previewHeight.h,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(color: AppColors.purple300, width: 1.w),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: GestureDetector(
                  onTap: onReplace,
                  child: Image.file(
                    File(imagePath),
                    width: double.infinity,
                    height: AnnouncementImagePreviewStyle.previewHeight.h,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          if (onRemove != null)
            Positioned(
              top: AnnouncementImagePreviewStyle.deleteButtonTop.h,
              right: AnnouncementImagePreviewStyle.deleteButtonEnd.w,
              child: _AnnouncementImageDeleteButton(onTap: onRemove!),
            ),
        ],
      ),
    );
  }
}

class _AnnouncementImageDeleteButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AnnouncementImageDeleteButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final size = AnnouncementImagePreviewStyle.deleteButtonSize.w;
    final iconSize = AnnouncementImagePreviewStyle.deleteIconSize.w;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(
            alpha: AnnouncementImagePreviewStyle.deleteButtonBackgroundOpacity,
          ),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: SvgPicture.asset(
            AppAssets.iconDelete,
            width: iconSize,
            height: iconSize,
            colorFilter: const ColorFilter.mode(
              AppColors.red900,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}
