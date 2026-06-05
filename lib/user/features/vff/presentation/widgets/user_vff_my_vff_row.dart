import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_network_avatar.dart';
import 'package:vestie/core/widgets/common/app_svg_icon.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/user/features/vff/presentation/models/user_vff_hub_ui_model.dart';

/// **Flow: Hub → “My VFFs” tab** — one connection card (Figma list row).
class UserVffMyVffRow extends StatelessWidget {
  final UserVffConnectionRowUi row;
  final VoidCallback? onOpen;

  const UserVffMyVffRow({
    super.key,
    required this.row,
    this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final canOpen = onOpen != null && !row.isPendingSent;

    return Padding(
      padding: EdgeInsets.only(bottom: AppDimens.v12),
      child: Material(
        color: AppColors.grey100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: const BorderSide(color: AppColors.cardBorder, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: canOpen ? onOpen : null,
          child: Padding(
            padding: EdgeInsets.all(AppDimens.p16),
            child: Row(
              children: [
                AppNetworkAvatar(
                  imageUrl: row.photoUrl,
                  initials: row.initials,
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
                        row.name,
                        style: GoogleFonts.lato(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.neutral1200,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      AppText(
                        row.mutualLabel,
                        style: GoogleFonts.lato(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.grey800,
                        ),
                      ),
                    ],
                  ),
                ),
                if (row.isPendingSent)
                  const _RequestSentBadge()
                else
                  AppSvgIcon(
                    assetPath: AppAssets.iconChevronRight,
                    color: AppColors.purple1000,
                    size: 22.r,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RequestSentBadge extends StatelessWidget {
  const _RequestSentBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.vffRequestSentChipBg,
        borderRadius: BorderRadius.circular(AppRadius.vffHubRequestActionButton),
        border: Border.all(color: AppColors.vffRequestSentChipBorder, width: 1),
      ),
      child: AppText(
        AppStrings.userVffStatusRequestSentSmall,
        style: GoogleFonts.lato(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.vffRequestSentChipLabel,
        ),
      ),
    );
  }
}
