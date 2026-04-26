import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_assets.dart';
import '../../constants/app_strings.dart';
import '../../theme/app_colors.dart';
import '../text/app_text.dart';

/// Action enum for each leader menu item.
enum LeaderMenuAction {
  joinRequests,
  addAnnouncement,
  editProject,
  inviteMembers,
  markSuccessful,
  cancelProject,
}

/// Reusable "..." popup menu for project leaders.
/// Renders a `PopupMenuButton` that follows the Figma design:
/// white card, dividers, color-coded items.
/// Pass [joinRequestCount] to show the badge on Join Requests.
class LeaderActionMenu extends StatelessWidget {
  final int joinRequestCount;
  final void Function(LeaderMenuAction) onSelected;

  const LeaderActionMenu({
    super.key,
    required this.onSelected,
    this.joinRequestCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<LeaderMenuAction>(
      offset: Offset(0, 34.h),
      constraints: BoxConstraints(minWidth: 282.w),
      color: AppColors.background,
      elevation: 6,
      shadowColor: AppColors.grey900.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: BorderSide(color: AppColors.grey300, width: 1),
      ),
      onSelected: onSelected,
      itemBuilder: (_) => [
        _buildItem(
          value: LeaderMenuAction.joinRequests,
          iconPath: AppAssets.iconJoinRequest,
          label: AppStrings.menuJoinRequests,
          badge: joinRequestCount > 0 ? joinRequestCount : null,
          iconColor: AppColors.primary,
          labelColor: AppColors.grey1100,
        ),
        _divider(),
        _buildItem(
          value: LeaderMenuAction.addAnnouncement,
          iconPath: AppAssets.iconAddAnnouncement,
          label: AppStrings.menuAddAnnouncement,
          iconColor: AppColors.primary,
          labelColor: AppColors.grey1100,
        ),
        _divider(),
        _buildItem(
          value: LeaderMenuAction.editProject,
          iconPath: AppAssets.iconEditProject,
          label: AppStrings.menuEditProject,
          iconColor: AppColors.primary,
          labelColor: AppColors.grey1100,
        ),
        _divider(),
        _buildItem(
          value: LeaderMenuAction.inviteMembers,
          iconPath: AppAssets.plusSign,
          label: AppStrings.menuInviteMembers,
          iconColor: AppColors.primary,
          labelColor: AppColors.grey1100,
        ),
        _divider(),
        _buildItem(
          value: LeaderMenuAction.markSuccessful,
          iconPath: AppAssets.checkMarkSuccessful,
          label: AppStrings.menuMarkSuccessful,
          iconColor: AppColors.green1000,
          labelColor: AppColors.badgeCompletedText,
        ),
        _divider(),
        _buildItem(
          value: LeaderMenuAction.cancelProject,
          iconPath: AppAssets.iconCancelProject,
          label: AppStrings.menuCancelProject,
          iconColor: AppColors.red900,
          labelColor: AppColors.red900,
        ),
      ],
      child: Container(
        width: 30.w,
        height: 30.w,
        alignment: Alignment.center,
        child: SvgPicture.asset(
          AppAssets.iconPopMenu,
          width: 22.w,
          height: 22.w,
          colorFilter: ColorFilter.mode(
            AppColors.grey1000,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }

  // ── Helper: build a menu item ──────────────────────────────────────────────
  PopupMenuItem<LeaderMenuAction> _buildItem({
    required LeaderMenuAction value,
    String? iconPath,
    required String label,
    required Color iconColor,
    required Color labelColor,
    int? badge,
  }) {
    return PopupMenuItem<LeaderMenuAction>(
      value: value,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon — SVG or Material
          SizedBox(
            width: 50.w,
            height: 24.w,
            child: SvgPicture.asset(
                    iconPath!,
                    colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                  )

          ),
          SizedBox(width: 3.w),

          // Label
          Expanded(
            child: AppText(
              label,
              style: GoogleFonts.lato(
                fontSize: 19.sp,
                fontWeight: FontWeight.w600,
                color: labelColor,
              ),
            ),
          ),

          // Badge count
          if (badge != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppColors.grey200,
                borderRadius: BorderRadius.circular(100.r),
              ),
              child: AppText(
                '$badge',
                style: GoogleFonts.lato(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textBody,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Helper: build a thin divider ──────────────────────────────────────────
  PopupMenuDivider _divider() =>
      PopupMenuDivider(height: 1.h,color: AppColors.neutral300,);
}
