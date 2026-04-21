import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../constants/app_strings.dart';
import '../../theme/app_colors.dart';
import '../text/app_text.dart';

class AppActionBottomSheet extends StatelessWidget {
  final String title;
  final String description;
  final String primaryLabel;
  final String secondaryLabel;
  final bool showSecondary;
  final Color primaryColor;
  final Color primaryTextColor;
  final String? iconAsset;
  final IconData? iconData;
  final Color? iconColor;
  final VoidCallback onPrimary;
  final VoidCallback onSecondary;

  const AppActionBottomSheet({
    super.key,
    required this.title,
    required this.description,
    required this.primaryLabel,
    required this.secondaryLabel,
    this.showSecondary = true,
    required this.primaryColor,
    this.primaryTextColor = AppColors.surface,
    required this.onPrimary,
    required this.onSecondary,
    this.iconAsset,
    this.iconData,
    this.iconColor,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String description,
    required String primaryLabel,
    String secondaryLabel = AppStrings.btnNo,
    bool showSecondary = true,
    required Color primaryColor,
    Color primaryTextColor = AppColors.surface,
    String? iconAsset,
    IconData? iconData,
    Color? iconColor,
    required VoidCallback onPrimary,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => AppActionBottomSheet(
        title: title,
        description: description,
        primaryLabel: primaryLabel,
        secondaryLabel: secondaryLabel,
        showSecondary: showSecondary,
        primaryColor: primaryColor,
        primaryTextColor: primaryTextColor,
        iconAsset: iconAsset,
        iconData: iconData,
        iconColor: iconColor,
        onPrimary: onPrimary,
        onSecondary: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
      child: Container(
        padding: EdgeInsets.fromLTRB(18.w, 20.h, 18.w, 18.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(28.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconAsset != null || iconData != null) ...[
              _SheetIcon(
                iconAsset: iconAsset,
                iconData: iconData,
                iconColor: iconColor,
              ),
              SizedBox(height: 12.h),
            ],
            AppText(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 38.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.grey1100,
                  ),
            ),
            SizedBox(height: 10.h),
            AppText(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 16.sp,
                    color: AppColors.grey900,
                    height: 1.5,
                  ),
            ),
            SizedBox(height: 22.h),
            _SheetButton(
              label: primaryLabel,
              onTap: onPrimary,
              textColor: primaryTextColor,
              bgColor: primaryColor,
              borderColor: primaryColor,
            ),
            if (showSecondary) ...[
              SizedBox(height: 10.h),
              _SheetButton(
                label: secondaryLabel,
                onTap: onSecondary,
                textColor: AppColors.neutral1200,
                bgColor: Colors.transparent,
                borderColor: AppColors.neutral1200,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SheetIcon extends StatelessWidget {
  final String? iconAsset;
  final IconData? iconData;
  final Color? iconColor;

  const _SheetIcon({this.iconAsset, this.iconData, this.iconColor});

  @override
  Widget build(BuildContext context) {
    if (iconAsset != null) {
      final isSvg = iconAsset!.toLowerCase().endsWith('.svg');
      return SizedBox(
        width: 74.w,
        height: 74.w,
        child: isSvg
            ? SvgPicture.asset(iconAsset!)
            : Image.asset(iconAsset!, fit: BoxFit.contain),
      );
    }
    return Container(
      width: 74.w,
      height: 74.w,
      decoration: BoxDecoration(
        color: (iconColor ?? AppColors.primary).withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData ?? Icons.check_rounded,
        color: iconColor ?? AppColors.primary,
        size: 46.w,
      ),
    );
  }
}

class _SheetButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color textColor;
  final Color bgColor;
  final Color borderColor;

  const _SheetButton({
    required this.label,
    required this.onTap,
    required this.textColor,
    required this.bgColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 13.h),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(color: borderColor),
        ),
        child: Center(
          child: AppText(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
          ),
        ),
      ),
    );
  }
}
