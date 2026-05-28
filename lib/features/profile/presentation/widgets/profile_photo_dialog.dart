import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/app_button.dart';
import '../../../../core/widgets/common/app_network_avatar.dart';
import '../../../../core/widgets/common/app_outline_neutral_button.dart';
import '../../../../core/widgets/common/app_svg_icon.dart';

/// Figma “Image Container” — preview photo with change / remove actions.
class ProfilePhotoDialog extends StatelessWidget {
  final String? photoUrl;
  final String initials;
  final VoidCallback onChangeImage;
  final VoidCallback onRemoveImage;

  const ProfilePhotoDialog({
    super.key,
    required this.photoUrl,
    required this.initials,
    required this.onChangeImage,
    required this.onRemoveImage,
  });

  static Future<void> show(
    BuildContext context, {
    required String? photoUrl,
    required String initials,
    required VoidCallback onChangeImage,
    required VoidCallback onRemoveImage,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (ctx) => ProfilePhotoDialog(
        photoUrl: photoUrl,
        initials: initials,
        onChangeImage: onChangeImage,
        onRemoveImage: onRemoveImage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Container(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: 32.w, minHeight: 32.w),
                icon: AppSvgIcon(
                  assetPath: AppAssets.iconClose,
                  size: 20.w,
                  color: const Color(0xFF381A7A),
                ),
              ),
            ),
            AppNetworkAvatar(
              imageUrl: photoUrl,
              initials: initials,
              size: 120.r,
              backgroundColor: AppColors.cardBorder,
              fontSize: 32.sp,
            ),
            SizedBox(height: 28.h),
            AppButton(
              text: AppStrings.profileChangeImage,
              onPressed: () {
                Navigator.of(context).pop();
                onChangeImage();
              },
              useGradient: false,
              color: AppColors.purple700,
              hasShadow: false,
              height: 38.h,
              borderRadius: AppRadius.r8,
              labelFontSize: 16.sp,
            ),
            SizedBox(height: 12.h),
            AppOutlineNeutralButton(
              label: AppStrings.profileRemoveImage,
              onPressed: () {
                Navigator.of(context).pop();
                onRemoveImage();
              },
              height: 38.h,
              borderRadius: AppRadius.r8,
              borderColor: AppColors.grey1100,
              labelColor: AppColors.grey1100,
            ),
          ],
        ),
      ),
    );
  }
}
