import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_assets.dart';
import '../../constants/app_strings.dart';
import '../../theme/app_colors.dart';
import '../text/app_text.dart';

/// Leader / co-leader actions. [joinRequests] is not in [LeaderActionMenu] — use the
/// header chip on project detail instead.
enum LeaderMenuAction {
  joinRequests,
  addAnnouncement,
  editProject,
  projectFundsHistory,
  myBorrows,
  inviteMembers,
  markSuccessful,
  stopContributions,
  cancelProject,
  leaveProject,
}

/// Storyboard distinction: primary owner sees success/cancel ownership actions.
enum LeaderMenuAudience { primaryLeader, coLeader }

/// Reusable "..." popup for project moderators (`LeaderMenuAudience`).
class LeaderActionMenu extends StatelessWidget {
  final LeaderMenuAudience audience;
  final bool includeMyBorrows;
  final void Function(LeaderMenuAction) onSelected;

  const LeaderActionMenu({
    super.key,
    required this.onSelected,
    this.audience = LeaderMenuAudience.primaryLeader,
    this.includeMyBorrows = false,
  });

  static const _primaryLabelColor = AppColors.grey900;
  static const _primaryIconColor = AppColors.primary;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<LeaderMenuAction>(
      offset: Offset(0, 34.h),
      constraints: BoxConstraints(minWidth: 282.w),
      color: AppColors.surface,
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
          AppAssets.iconMoreOptions,
          width: 30.w,
          height: 30.w,
          colorFilter: ColorFilter.mode(AppColors.grey1000, BlendMode.srcIn),
        ),
      ),
    );
  }

  List<PopupMenuEntry<LeaderMenuAction>> _buildEntries() {
    return audience == LeaderMenuAudience.coLeader
        ? _coLeaderEntries()
        : _primaryLeaderEntries();
  }

  /// Figma “GL Popup - Action Popup 4” (CoLeader).
  List<PopupMenuEntry<LeaderMenuAction>> _coLeaderEntries() {
    final out = <PopupMenuEntry<LeaderMenuAction>>[];

    void push(LeaderMenuAction action, String icon, String label) {
      if (out.isNotEmpty) out.add(_divider());
      out.add(
        _buildItem(
          value: action,
          iconPath: icon,
          label: label,
          iconColor: _primaryIconColor,
          labelColor: _primaryLabelColor,
        ),
      );
    }

    push(
      LeaderMenuAction.addAnnouncement,
      AppAssets.leaderAddAnnouncement,
      AppStrings.menuAddAnnouncement,
    );
    push(
      LeaderMenuAction.projectFundsHistory,
      AppAssets.memberFundsHistory,
      AppStrings.menuProjectFundsHistory,
    );
    if (includeMyBorrows) {
      push(
        LeaderMenuAction.myBorrows,
        AppAssets.myBorrowsMenu,
        AppStrings.menuMyBorrows,
      );
    }
    push(
      LeaderMenuAction.inviteMembers,
      AppAssets.iconAdd,
      AppStrings.menuInviteMembers,
    );
    if (out.isNotEmpty) out.add(_divider());
    out.add(
      _buildItem(
        value: LeaderMenuAction.leaveProject,
        iconPath: AppAssets.memberLeaveProject,
        label: AppStrings.menuLeaveProject,
        iconColor: AppColors.red900,
        labelColor: AppColors.red900,
      ),
    );

    return out;
  }

  List<PopupMenuEntry<LeaderMenuAction>> _primaryLeaderEntries() {
    final out = <PopupMenuEntry<LeaderMenuAction>>[];

    void push(
      LeaderMenuAction action,
      String icon,
      String label, {
      Color? iconColor,
      Color? labelColor,
    }) {
      if (out.isNotEmpty) out.add(_divider());
      out.add(
        _buildItem(
          value: action,
          iconPath: icon,
          label: label,
          iconColor: iconColor ?? _primaryIconColor,
          labelColor: labelColor ?? _primaryLabelColor,
        ),
      );
    }

    push(
      LeaderMenuAction.addAnnouncement,
      AppAssets.leaderAddAnnouncement,
      AppStrings.menuAddAnnouncement,
    );
    push(
      LeaderMenuAction.editProject,
      AppAssets.leaderEditProject,
      AppStrings.menuEditProject,
    );
    push(
      LeaderMenuAction.projectFundsHistory,
      AppAssets.memberFundsHistory,
      AppStrings.menuProjectFundsHistory,
    );
    if (includeMyBorrows) {
      push(
        LeaderMenuAction.myBorrows,
        AppAssets.myBorrowsMenu,
        AppStrings.menuMyBorrows,
      );
    }
    push(
      LeaderMenuAction.inviteMembers,
      AppAssets.iconAdd,
      AppStrings.menuInviteMembers,
    );
    push(
      LeaderMenuAction.markSuccessful,
      AppAssets.leaderMarkSuccessful,
      AppStrings.menuMarkSuccessful,
      iconColor: AppColors.green900,
      labelColor: AppColors.green900,
    );
    push(
      LeaderMenuAction.stopContributions,
      AppAssets.leaderStopContributions,
      AppStrings.menuStopContributions,
      iconColor: AppColors.actionStopContributions,
      labelColor: AppColors.actionStopContributions,
    );
    push(
      LeaderMenuAction.cancelProject,
      AppAssets.leaderCancelProject,
      AppStrings.menuCancelProject,
      iconColor: AppColors.red900,
      labelColor: AppColors.red900,
    );

    return out;
  }

  PopupMenuItem<LeaderMenuAction> _buildItem({
    required LeaderMenuAction value,
    String? iconPath,
    required String label,
    required Color iconColor,
    required Color labelColor,
  }) {
    return PopupMenuItem<LeaderMenuAction>(
      value: value,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            iconPath!,
            width: 30.w,
            height: 30.w,
            fit: BoxFit.contain,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: AppText(
              label,
              style: GoogleFonts.lato(
                fontSize: 20.sp,
                fontWeight: FontWeight.w500,
                color: labelColor,
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
