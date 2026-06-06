import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../constants/app_assets.dart';
import '../../constants/app_dimens.dart';
import '../../constants/app_strings.dart';
import '../../theme/app_colors.dart';
import '../text/app_text.dart';
import 'app_svg_icon.dart';
import 'failure_icon.dart';
import 'success_dialog_icon.dart';

class AppActionDialog extends StatelessWidget {
  final String title;
  final String description;
  final Widget? descriptionWidget;
  final String primaryLabel;
  final String secondaryLabel;
  final bool showSecondary;
  final Color primaryColor;
  final Color primaryTextColor;
  final Color? primaryBorderColor;
  final String? iconAsset;
  final String? glyphAsset;
  final Color? iconColor;
  final bool actionsInRow;
  final VoidCallback onPrimary;
  final VoidCallback onSecondary;

  const AppActionDialog({
    super.key,
    required this.title,
    required this.description,
    this.descriptionWidget,
    required this.primaryLabel,
    required this.secondaryLabel,
    this.showSecondary = true,
    required this.primaryColor,
    this.primaryTextColor = AppColors.surface,
    this.primaryBorderColor,
    required this.onPrimary,
    required this.onSecondary,
    this.iconAsset,
    this.glyphAsset,
    this.iconColor,
    this.actionsInRow = false,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String description,
    Widget? descriptionWidget,
    required String primaryLabel,
    String secondaryLabel = AppStrings.btnNo,
    bool showSecondary = true,
    required Color primaryColor,
    Color primaryTextColor = AppColors.surface,
    Color? primaryBorderColor,
    String? iconAsset,
    String? glyphAsset,
    Color? iconColor,
    bool actionsInRow = false,
    required VoidCallback onPrimary,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 15.w),
        child: AppActionDialog(
          title: title,
          description: description,
          descriptionWidget: descriptionWidget,
          primaryLabel: primaryLabel,
          secondaryLabel: secondaryLabel,
          showSecondary: showSecondary,
          primaryColor: primaryColor,
          primaryTextColor: primaryTextColor,
          primaryBorderColor: primaryBorderColor,
          iconAsset: iconAsset,
          glyphAsset: glyphAsset,
          iconColor: iconColor,
          actionsInRow: actionsInRow,
          onPrimary: onPrimary,
          onSecondary: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  /// Success result dialog with [AppAssets.successProjectCreated] and filled primary CTA.
  static Future<void> showSuccessOk(
    BuildContext context, {
    required String title,
    String description = '',
    Widget? descriptionWidget,
    String primaryLabel = AppStrings.btnBackToProject,
    required VoidCallback onPrimary,
  }) {
    return show(
      context,
      title: title,
      description: description,
      descriptionWidget: descriptionWidget,
      primaryLabel: primaryLabel,
      showSecondary: false,
      primaryColor: AppColors.neutral1200,
      primaryTextColor: AppColors.surface,
      primaryBorderColor: AppColors.neutral1200,
      iconAsset: AppAssets.successProjectCreated,
      onPrimary: onPrimary,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        18.w,
        35.h,
        18.w,
        AppDimens.dialogActionBottomInset,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (iconAsset != null || glyphAsset != null) ...[
            _DialogIcon(
              iconAsset: iconAsset,
              glyphAsset: glyphAsset,
              iconColor: iconColor,
            ),
            SizedBox(height: 6.h),
          ],
          AppText(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 26.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.grey1100,
            ),
          ),
          SizedBox(height: 6.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.w),
            child:
                descriptionWidget ??
                AppText(
                  description,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.grey900,
                    height: 1.5,
                  ),
                ),
          ),
          SizedBox(height: 35.h),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildActions() {
    final primary = _DialogButton(
      label: primaryLabel,
      onTap: onPrimary,
      textColor: primaryTextColor,
      bgColor: primaryColor,
      borderColor: primaryBorderColor ?? primaryColor,
    );
    if (!showSecondary) {
      return primary;
    }
    final secondary = _DialogButton(
      label: secondaryLabel,
      onTap: onSecondary,
      textColor: AppColors.neutral1200,
      bgColor: Colors.transparent,
      borderColor: AppColors.neutral1200,
    );
    if (actionsInRow) {
      return Row(
        children: [
          Expanded(child: secondary),
          SizedBox(width: 12.w),
          Expanded(child: primary),
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        primary,
        SizedBox(height: 10.h),
        secondary,
      ],
    );
  }
}

class _DialogIcon extends StatelessWidget {
  final String? iconAsset;
  final String? glyphAsset;
  final Color? iconColor;

  const _DialogIcon({this.iconAsset, this.glyphAsset, this.iconColor});

  @override
  Widget build(BuildContext context) {
    if (iconAsset != null) {
      if (iconAsset == AppAssets.statusFailure) {
        return const FailureIcon();
      }
      if (iconAsset == AppAssets.successProjectCreated) {
        return const SuccessDialogIcon();
      }
      final isSvg = iconAsset!.toLowerCase().endsWith('.svg');
      return SizedBox(
        width: AppDimens.dialogHeroIconWidth,
        height: AppDimens.dialogHeroIconHeight,
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
      child: Center(
        child: AppSvgIcon(
          assetPath: glyphAsset ?? AppAssets.iconCheckCircle,
          size: 46.w,
          color: iconColor ?? AppColors.primary,
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color textColor;
  final Color bgColor;
  final Color borderColor;

  const _DialogButton({
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
      borderRadius: BorderRadius.circular(AppRadius.dialogActionButton),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 13.h),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppRadius.dialogActionButton),
          border: Border.all(color: borderColor),
        ),
        child: Center(
          child: AppText(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
