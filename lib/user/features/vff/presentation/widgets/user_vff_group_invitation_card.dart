import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/user/features/vff/presentation/models/user_vff_hub_ui_model.dart';
import 'package:vestie/user/features/vff/presentation/models/user_vff_inbox_action.dart';
import 'package:vestie/user/features/vff/presentation/widgets/user_vff_hub_request_action_buttons.dart';

/// **Flow: Hub Requests tab / group-invites list** — project or member-join invite.
class UserVffGroupInvitationCard extends StatelessWidget {
  final UserVffGroupInviteUi item;
  final VoidCallback? onPrimary;
  final VoidCallback? onDecline;
  final UserVffInboxRowAction? actingRow;

  const UserVffGroupInvitationCard({
    super.key,
    required this.item,
    required this.onPrimary,
    required this.onDecline,
    this.actingRow,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = '${AppStrings.userVffInvitedBy} ${item.invitedByName}';
    final primaryLabel =
        item.kind == UserVffGroupInviteKind.memberRequestJoin ||
                item.primaryIsRequestToJoin
            ? AppStrings.userVffRequestToJoin
            : AppStrings.btnJoin;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Material(
        color: AppColors.grey100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: const BorderSide(color: AppColors.neutral400, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                item.titleLine,
                style: GoogleFonts.lato(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral1200,
                ),
              ),
              SizedBox(height: 2.h),
              AppText(
                subtitle,
                style: GoogleFonts.lato(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey800,
                ),
              ),
              SizedBox(height: 14.h),
              UserVffHubRequestActionButtons(
                primaryLabel: primaryLabel,
                onPrimary: onPrimary,
                onDecline: onDecline,
                isPrimaryLoading: actingRow.primaryLoading(
                  item.id,
                  UserVffInboxItemKind.projectInvite,
                ),
                isDeclineLoading: actingRow.declineLoading(
                  item.id,
                  UserVffInboxItemKind.projectInvite,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
