import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_avatar_circle.dart';
import 'package:vestie/core/widgets/common/app_svg_icon.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/user/features/vff/presentation/models/user_vff_hub_ui_model.dart';
import 'package:vestie/user/features/vff/presentation/widgets/user_vff_outline_button_compact.dart';

/// **Flow: Hub Requests tab / group-invites list** — project or member-join invite.
class UserVffGroupInvitationCard extends StatelessWidget {
  final UserVffGroupInviteUi item;
  final VoidCallback onPrimary;
  final VoidCallback onDecline;

  const UserVffGroupInvitationCard({
    super.key,
    required this.item,
    required this.onPrimary,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle =
        '${AppStrings.userVffInvitedBy} ${item.invitedByName}';
    final isProject = item.kind == UserVffGroupInviteKind.project;

    final primaryLabel =
        isProject ? AppStrings.btnJoin : AppStrings.userVffRequestToJoin;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 16.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isProject)
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: AppColors.purple100,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(
                    child: AppSvgIcon(
                      assetPath: AppAssets.iconGroups,
                      size: 28.r,
                      color: AppColors.primaryDark,
                    ),
                  ),
                )
              else
                AppAvatarCircle(
                  initials:
                      item.personInitials.isNotEmpty ? item.personInitials : '?',
                  size: 48.r,
                  backgroundColor: AppColors.purple200,
                  textColor: AppColors.grey1100,
                  fontSize: 13.sp,
                ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      item.titleLine,
                      style: GoogleFonts.lato(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.grey1100,
                      ),
                    ),
                    if (isProject) ...[
                      SizedBox(height: 2.h),
                      AppText(
                        '${item.memberCount} ${AppStrings.userVffMembersCountSuffix}',
                        style: GoogleFonts.lato(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textBody,
                        ),
                      ),
                    ],
                    SizedBox(height: 2.h),
                    AppText(
                      subtitle,
                      style: GoogleFonts.lato(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textBody,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: primaryLabel,
                  height: 48.h,
                  onPressed: onPrimary,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: UserVffOutlineButtonCompact(
                  label: AppStrings.btnDecline,
                  onTap: onDecline,
                  height: 48.h,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
