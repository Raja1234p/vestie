import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_success_screen.dart';
import 'package:vestie/core/widgets/text/app_text.dart';

/// **Flow: Invite members** → “Invites Sent!” (`AppSuccessScreen`, shared with other flows).
final class UserVffInvitesSentScreen extends StatelessWidget {
  final int inviteCount;
  final String projectName;

  const UserVffInvitesSentScreen({
    super.key,
    required this.inviteCount,
    required this.projectName,
  });

  @override
  Widget build(BuildContext context) {
    return AppSuccessScreen(
      illustrationAsset: AppAssets.successProjectJoined,
      title: AppStrings.userVffInviteSuccessTitle,
      subtitleWidget: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText(
              AppStrings.userVffInviteSubtitle(inviteCount),
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 20.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.grey800,
                height: 1.35,
              ),
            ),
            SizedBox(height: 8.h),
            AppText(
              projectName,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.grey1100,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
      buttonText: AppStrings.btnDone,
      onButtonPressed: () => context.go(AppRoutes.dashboard),
    );
  }
}
