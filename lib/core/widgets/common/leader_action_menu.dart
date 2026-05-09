import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_assets.dart';
import '../../constants/app_strings.dart';
import '../../theme/app_colors.dart';
import '../text/app_text.dart';

/// Action enum for leader / co-leader overflow menu items.
enum LeaderMenuAction {
  projectSettings,
  joinRequests,
  addAnnouncement,
  editProject,
  inviteMembers,
  markSuccessful,
  cancelProject,
}

/// Storyboard distinction: primary owner sees success/cancel ownership actions.
enum LeaderMenuAudience {
  primaryLeader,
  coLeader,
}

/// Reusable "..." popup for project moderators (`LeaderMenuAudience`).
class LeaderActionMenu extends StatelessWidget {
  final LeaderMenuAudience audience;
  final int joinRequestCount;
  final void Function(LeaderMenuAction) onSelected;

  const LeaderActionMenu({
    super.key,
    required this.onSelected,
    this.audience = LeaderMenuAudience.primaryLeader,
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
      itemBuilder: (_) => _buildEntries(),
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

  List<PopupMenuEntry<LeaderMenuAction>> _buildEntries() {
    final out = <PopupMenuEntry<LeaderMenuAction>>[];

    void push(PopupMenuItem<LeaderMenuAction> item) {
      if (out.isNotEmpty) out.add(_divider());
      out.add(item);
    }

    push(
      _buildItem(
        value: LeaderMenuAction.projectSettings,
        iconPath: AppAssets.iconEditProject,
        label: AppStrings.menuLeaderProjectSettings,
        iconColor: AppColors.primary,
        labelColor: AppColors.grey1100,
      ),
    );
    push(
      _buildItem(
        value: LeaderMenuAction.joinRequests,
        iconPath: AppAssets.iconJoinRequest,
        label: AppStrings.menuJoinRequests,
        badge: joinRequestCount > 0 ? joinRequestCount : null,
        iconColor: AppColors.primary,
        labelColor: AppColors.grey1100,
      ),
    );
    push(
      _buildItem(
        value: LeaderMenuAction.addAnnouncement,
        iconPath: AppAssets.iconAddAnnouncement,
        label: AppStrings.menuAddAnnouncement,
        iconColor: AppColors.primary,
        labelColor: AppColors.grey1100,
      ),
    );
    push(
      _buildItem(
        value: LeaderMenuAction.editProject,
        iconPath: AppAssets.iconEditProject,
        label: AppStrings.menuEditProject,
        iconColor: AppColors.primary,
        labelColor: AppColors.grey1100,
      ),
    );
    push(
      _buildItem(
        value: LeaderMenuAction.inviteMembers,
        iconPath: AppAssets.plusSign,
        label: AppStrings.menuInviteMembers,
        iconColor: AppColors.primary,
        labelColor: AppColors.grey1100,
      ),
    );

    if (audience == LeaderMenuAudience.primaryLeader) {
      push(
        _buildItem(
          value: LeaderMenuAction.markSuccessful,
          iconPath: AppAssets.checkMarkSuccessful,
          label: AppStrings.menuMarkSuccessful,
          iconColor: AppColors.green1000,
          labelColor: AppColors.badgeCompletedText,
        ),
      );
      push(
        _buildItem(
          value: LeaderMenuAction.cancelProject,
          iconPath: AppAssets.iconCancelProject,
          label: AppStrings.menuCancelProject,
          iconColor: AppColors.red900,
          labelColor: AppColors.red900,
        ),
      );
    }

    return out;
  }

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
          SizedBox(
            width: 50.w,
            height: 24.w,
            child: SvgPicture.asset(
              iconPath!,
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            ),
          ),
          SizedBox(width: 3.w),
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

  PopupMenuDivider _divider() =>
      PopupMenuDivider(height: 1.h, color: AppColors.neutral300);
}
