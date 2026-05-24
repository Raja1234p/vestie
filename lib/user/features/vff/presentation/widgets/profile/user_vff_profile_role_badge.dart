import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_member_vff_badge.dart';
import '../../models/user_vff_profile_ui_model.dart';

/// Member vs VFF pill under the avatar (VFF uses [ProjectMemberVffBadge]).
final class UserVffProfileRoleBadge extends StatelessWidget {
  final UserVffProfileUiModel profile;

  const UserVffProfileRoleBadge({super.key, required this.profile});

  bool get _showsVffBadge =>
      profile.badgeMode == UserVffProfileBadgeMode.vffVerified ||
      profile.footerMode == UserVffProfileFooterMode.followingSheet;

  @override
  Widget build(BuildContext context) {
    if (_showsVffBadge) {
      return const ProjectMemberVffBadge();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: AppColors.purple100,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: AppColors.purple300),
      ),
      child: AppText(
        AppStrings.userVffBadgeMember,
        style: GoogleFonts.lato(
          fontSize: 11.sp,
          fontWeight: FontWeight.w800,
          color: AppColors.primaryDark,
        ),
      ),
    );
  }
}
