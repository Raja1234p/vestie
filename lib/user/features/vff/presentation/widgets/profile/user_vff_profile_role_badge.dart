import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_svg_icon.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import '../../models/user_vff_profile_ui_model.dart';

/// Member vs VFF pill under the avatar.
final class UserVffProfileRoleBadge extends StatelessWidget {
  final UserVffProfileUiModel profile;

  const UserVffProfileRoleBadge({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final isFollowingUi =
        profile.footerMode == UserVffProfileFooterMode.followingSheet;
    final isVffBadge =
        profile.badgeMode == UserVffProfileBadgeMode.vffVerified;
    final showCrown = isFollowingUi || isVffBadge;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: AppColors.purple100,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: AppColors.purple300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showCrown) ...[
            AppSvgIcon(
              assetPath: AppAssets.crown,
              size: 14.r,
              color: AppColors.primaryDark,
            ),
            SizedBox(width: 4.w),
          ],
          AppText(
            isFollowingUi
                ? AppStrings.userVffBadgeVff
                : AppStrings.userVffBadgeMember,
            style: GoogleFonts.lato(
              fontSize: 11.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }
}
