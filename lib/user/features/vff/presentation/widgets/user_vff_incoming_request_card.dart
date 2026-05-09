import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_avatar_circle.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/user/features/vff/presentation/models/user_vff_hub_ui_model.dart';
import 'package:vestie/user/features/vff/presentation/widgets/user_vff_outline_button_compact.dart';

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
    final via =
        '${AppStrings.userVffViaProject} ${item.viaProjectName}';

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
            children: [
              AppAvatarCircle(
                initials: item.initials,
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
                      item.name,
                      style: GoogleFonts.lato(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.grey1100,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    AppText(
                      via,
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
                  text: AppStrings.btnAccept,
                  height: 48.h,
                  onPressed: onAccept,
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
