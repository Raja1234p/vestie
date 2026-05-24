import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_network_avatar.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import '../../models/user_vff_profile_ui_model.dart';
import 'user_vff_profile_role_badge.dart';

/// Avatar + badge + name row for VFF profile.
final class UserVffProfileIdentitySection extends StatelessWidget {
  final UserVffProfileUiModel profile;

  const UserVffProfileIdentitySection({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final p = profile;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppNetworkAvatar(
          imageUrl: p.photoUrl,
          initials: p.initials,
          size: 100.r,
          backgroundColor: AppColors.purple200,
          textColor: AppColors.grey1100,
          fontSize: 28.sp,
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserVffProfileRoleBadge(profile: p),
              SizedBox(height: 6.h),
              AppText(
                p.displayName,
                style: GoogleFonts.lato(
                  fontSize: 21.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.grey1100,
                ),
              ),
              if (p.hasUsername)
                AppText(
                  '@${p.usernameHandle}',
                  style: GoogleFonts.lato(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textBody,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
