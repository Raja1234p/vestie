import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_assets.dart';
import '../../constants/app_strings.dart';
import '../../theme/app_colors.dart';

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
      offset: Offset(0, 40.h),
      color: AppColors.surface,
      elevation: 8,
      shadowColor: AppColors.grey900.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(color: AppColors.border, width: 1),
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
          icon: Icons.add,
          label: AppStrings.menuInviteMembers,
          iconColor: AppColors.primary,
          labelColor: AppColors.grey1100,
        ),
        _divider(),
        _buildItem(
          value: LeaderMenuAction.markSuccessful,
          iconPath: AppAssets.iconMarkSuccessful,
          label: AppStrings.menuMarkSuccessful,
          iconColor: AppColors.success,
          labelColor: AppColors.success,
        ),
        _divider(),
        _buildItem(
          value: LeaderMenuAction.cancelProject,
          iconPath: AppAssets.iconCancelProject,
          label: AppStrings.menuCancelProject,
          iconColor: AppColors.error,
          labelColor: AppColors.error,
        ),
      ],
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          color: AppColors.grey200,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.more_horiz_rounded,
          size: 20.w,
          color: AppColors.grey1100,
        ),
      ),
    );
  }

  // ── Helper: build a menu item ──────────────────────────────────────────────
  PopupMenuItem<LeaderMenuAction> _buildItem({
    required LeaderMenuAction value,
    String? iconPath,
    IconData? icon,
    required String label,
    required Color iconColor,
    required Color labelColor,
    int? badge,
  }) {
    return PopupMenuItem<LeaderMenuAction>(
      value: value,
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
      child: Row(
        children: [
          // Icon — SVG or Material
          SizedBox(
            width: 20.w,
            height: 20.w,
            child: iconPath != null
                ? SvgPicture.asset(
                    iconPath,
                    colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                  )
                : Icon(icon, size: 20.w, color: iconColor),
          ),
          SizedBox(width: 14.w),

          // Label
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.lato(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
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
              child: Text(
                '$badge',
                style: GoogleFonts.lato(
                  fontSize: 12.sp,
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
      PopupMenuDivider(height: 1);
}
