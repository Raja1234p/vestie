import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_network_avatar.dart';
import 'package:vestie/user/features/vff/presentation/models/user_vff_hub_ui_model.dart';
import 'package:vestie/user/features/vff/presentation/models/user_vff_inbox_action.dart';
import 'package:vestie/user/features/vff/presentation/widgets/user_vff_hub_request_action_buttons.dart';
import 'package:vestie/user/features/vff/presentation/widgets/user_vff_inbox_card_title_block.dart';

/// **Flow: Hub / VFF-requests list → “VFF Requests”** — inbound connection request row.
class UserVffIncomingRequestCard extends StatelessWidget {
  final UserVffIncomingRequestUi item;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final UserVffInboxRowAction? actingRow;
  final double? bottomSpacing;

  const UserVffIncomingRequestCard({
    super.key,
    required this.item,
    required this.onAccept,
    required this.onDecline,
    this.actingRow,
    this.bottomSpacing,
  });

  @override
  Widget build(BuildContext context) {
    final via = '${AppStrings.userVffViaProject} ${item.viaProjectName}';

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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppNetworkAvatar(
                imageUrl: item.photoUrl,
                initials: item.initials,
                size: 40.r,
                backgroundColor: AppColors.purple200,
                textColor: AppColors.grey1100,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UserVffInboxCardTitleBlock(title: item.name, subtitle: via),
                    SizedBox(height: 14.h),
                    UserVffHubRequestActionButtons(
                      primaryLabel: AppStrings.btnAccept,
                      onPrimary: onAccept,
                      onDecline: onDecline,
                      isPrimaryLoading: actingRow.primaryLoading(
                        item.id,
                        UserVffInboxItemKind.vffRequest,
                      ),
                      isDeclineLoading: actingRow.declineLoading(
                        item.id,
                        UserVffInboxItemKind.vffRequest,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
