import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/text/app_text.dart';

enum ProfileHeaderMenuAction { deleteAccount }

/// Profile tab header trailing control — opens more-options popup (Figma).
class ProfileHeaderMoreOptionsAction extends StatelessWidget {
  final void Function(ProfileHeaderMenuAction action)? onSelected;

  const ProfileHeaderMoreOptionsAction({super.key, this.onSelected});

  static const _destructiveColor = AppColors.profileDeleteAccountLabel;

  @override
  Widget build(BuildContext context) {
    final extent = AppDimens.iconLarge;
    return PopupMenuButton<ProfileHeaderMenuAction>(
      offset: Offset(0, 34.h),
      constraints: BoxConstraints(minWidth: 210.w),
      color: AppColors.surface,
      elevation: 6,
      shadowColor: AppColors.grey900.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: const BorderSide(color: AppColors.grey300, width: 1),
      ),
      onSelected: onSelected,
      itemBuilder: (_) => [
        PopupMenuItem<ProfileHeaderMenuAction>(
          value: ProfileHeaderMenuAction.deleteAccount,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                AppAssets.iconCancelProject,
                width: 26.w,
                height: 26.w,
                fit: BoxFit.contain,
                colorFilter: const ColorFilter.mode(
                  _destructiveColor,
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: AppText(
                  AppStrings.menuDeleteAccount,
                  style: GoogleFonts.lato(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w500,
                    color: _destructiveColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
      child: SizedBox(
        width: extent,
        height: extent,
        child: Center(
          child: SvgPicture.asset(
            AppAssets.iconMoreOptions,
            width: extent,
            height: extent,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
