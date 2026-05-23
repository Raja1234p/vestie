import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_avatar_circle.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/user/features/vff/presentation/models/user_vff_hub_ui_model.dart';
import 'package:vestie/user/features/vff/presentation/widgets/user_vff_hub_request_action_buttons.dart';

/// **Flow: Hub / VFF-requests list → “VFF Requests”** — inbound connection request row.
class UserVffIncomingRequestCard extends StatelessWidget {
  final UserVffIncomingRequestUi item;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const UserVffIncomingRequestCard({
    super.key,
    required this.item,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final via = '${AppStrings.userVffViaProject} ${item.viaProjectName}';

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
              Row(
                children: [
                  AppAvatarCircle(
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
                        AppText(
                          item.name,
                          style: GoogleFonts.lato(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.neutral1200,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        AppText(
                          via,
                          style: GoogleFonts.lato(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.grey800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              UserVffHubRequestActionButtons(
                primaryLabel: AppStrings.btnAccept,
                onPrimary: onAccept,
                onDecline: onDecline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
