import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_network_avatar.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_member_vff_badge.dart';
import '../../models/user_vff_profile_ui_model.dart';

/// Centered avatar + VFF badge + name (connected peer profile).
final class UserVffProfileConnectedHeader extends StatelessWidget {
  final UserVffProfileUiModel profile;

  const UserVffProfileConnectedHeader({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final p = profile;
    return Column(
      children: [
        AppNetworkAvatar(
          imageUrl: p.photoUrl,
          initials: p.initials,
          size: 100.r,
          backgroundColor: AppColors.purple200,
          textColor: AppColors.grey1100,
          fontSize: 28.sp,
        ),
        SizedBox(height: 10.h),
        const ProjectMemberVffBadge(),
        SizedBox(height: 10.h),
        AppText(
          p.displayName,
          textAlign: TextAlign.center,
          style: GoogleFonts.lato(
            fontSize: 21.sp,
            fontWeight: FontWeight.w900,
            color: AppColors.grey1100,
          ),
        ),
        if (p.hasUsername) ...[
          SizedBox(height: 4.h),
          AppText(
            '@${p.usernameHandle}',
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.grey800,
            ),
          ),
        ],
      ],
    );
  }
}
