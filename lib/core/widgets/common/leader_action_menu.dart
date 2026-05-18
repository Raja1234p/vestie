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
  final bool includeMyBorrows;
  final void Function(LeaderMenuAction) onSelected;

  const LeaderActionMenu({
    super.key,
    required this.onSelected,
    this.audience = LeaderMenuAudience.primaryLeader,
    this.includeMyBorrows = false,
  });

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
          AppAssets.iconPopMenu,
          width: 30.w,
          height: 30.w,
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
        value: LeaderMenuAction.addAnnouncement,
        iconPath: AppAssets.iconAddAnnouncement,
        label: AppStrings.menuAddAnnouncement,
        iconColor: AppColors.primary,
        labelColor: AppColors.grey900,
      ),
    );
    push(
      _buildItem(
        value: LeaderMenuAction.editProject,
        iconPath: AppAssets.iconEditProject,
        label: AppStrings.menuEditProject,
        iconColor: AppColors.primary,
        labelColor: AppColors.grey900,
      ),
    );
    push(
      _buildItem(
        value: LeaderMenuAction.projectFundsHistory,
        iconPath: AppAssets.iconProjectFundHistory,
        label: AppStrings.menuProjectFundsHistory,
        iconColor: AppColors.primary,
        labelColor: AppColors.grey900,
      ),
    );
    if (includeMyBorrows) {
      push(
        _buildItem(
          value: LeaderMenuAction.myBorrows,
          iconPath: AppAssets.iconMyBorrows,
          label: AppStrings.menuMyBorrows,
          iconColor: AppColors.primary,
          labelColor: AppColors.grey900,
        ),
      );
    }
    push(
      _buildItem(
        value: LeaderMenuAction.inviteMembers,
        iconPath: AppAssets.plusSign,
        label: AppStrings.menuInviteMembers,
        iconColor: AppColors.primary,
        labelColor: AppColors.grey900,
      ),
    );

    // GroupLeader only — CoLeader cannot mark successful / start success vote.
    if (audience == LeaderMenuAudience.primaryLeader) {
      push(
        _buildItem(
          value: LeaderMenuAction.markSuccessful,
          iconPath: AppAssets.iconMarkSuccessful,
          label: AppStrings.menuMarkSuccessful,
          iconColor: AppColors.green900,
          labelColor: AppColors.green900,
        ),
      );
    }
    push(
      _buildItem(
        value: LeaderMenuAction.cancelProject,
        iconPath: AppAssets.iconCancelProject,
        label: AppStrings.menuCancelProject,
        iconColor: AppColors.red900,
        labelColor: AppColors.red900,
      ),
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
