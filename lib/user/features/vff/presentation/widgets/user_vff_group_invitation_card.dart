import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/user/features/vff/presentation/models/user_vff_hub_ui_model.dart';
import 'package:vestie/user/features/vff/presentation/models/user_vff_inbox_action.dart';
import 'package:vestie/user/features/vff/presentation/widgets/user_vff_hub_request_action_buttons.dart';
import 'package:vestie/user/features/vff/presentation/widgets/user_vff_inbox_card_title_block.dart';

/// **Flow: Hub Requests tab / group-invites list** — project or member-join invite.
class UserVffGroupInvitationCard extends StatelessWidget {
  final UserVffGroupInviteUi item;
  final VoidCallback? onPrimary;
  final VoidCallback? onDecline;
  final UserVffInboxRowAction? actingRow;
  final double? bottomSpacing;

  const UserVffGroupInvitationCard({
    super.key,
    required this.item,
    required this.onPrimary,
    required this.onDecline,
    this.actingRow,
    this.bottomSpacing,
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
      padding: EdgeInsets.only(bottom: bottomSpacing ?? AppDimens.v12),
      child: Material(
        color: AppColors.vffInboxRequestCardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: const BorderSide(
            color: AppColors.vffInboxRequestCardBorder,
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: EdgeInsets.all(AppDimens.p16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserVffInboxCardTitleBlock(
                title: item.titleLine,
                subtitle: subtitle,
                titleSubtitleGap: 3.h,
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
