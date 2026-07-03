import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/app_assets.dart';
import '../../constants/app_strings.dart';
import '../../theme/app_colors.dart';
import '../text/app_text.dart';

/// “Project Actions” overflow — `Member` on investment / vacation / emergency detail.
enum MemberProjectMenuAction {
  projectFundsHistory,
  myBorrows,
  inviteMembers,
  leaveProject,
}

class MemberProjectActionMenu extends StatelessWidget {
  final void Function(MemberProjectMenuAction) onSelected;
  final bool includeMyBorrows;
  final bool fundsHistoryOnly;

  const MemberProjectActionMenu({
    super.key,
    required this.onSelected,
    this.includeMyBorrows = true,
    this.fundsHistoryOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<MemberProjectMenuAction>(
      offset: Offset(0, 34.h),
      constraints: BoxConstraints(minWidth: 282.w),
      color: AppColors.surface,
      elevation: 6,
      shadowColor: AppColors.grey900.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: const BorderSide(color: AppColors.grey300, width: 1),
      ),
      onSelected: onSelected,
      itemBuilder: (_) => _entries(),
      child: Container(
        width: 30.w,
        height: 30.w,
        alignment: Alignment.center,
        child: SvgPicture.asset(
          AppAssets.iconMoreOptions,
          width: 30.w,
          height: 30.w,
          colorFilter: const ColorFilter.mode(
            AppColors.grey1000,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }

  List<PopupMenuEntry<MemberProjectMenuAction>> _entries() {
    if (fundsHistoryOnly) {
      return [
        _item(
          value: MemberProjectMenuAction.projectFundsHistory,
          iconPath: AppAssets.memberFundsHistory,
          label: AppStrings.menuProjectFundsHistory,
          iconColor: AppColors.primary,
          labelColor: AppColors.grey900,
        ),
      ];
    }

    final out = <PopupMenuEntry<MemberProjectMenuAction>>[];

    void push(PopupMenuItem<MemberProjectMenuAction> item) {
      if (out.isNotEmpty) {
        out.add(PopupMenuDivider(height: 1.h, color: AppColors.neutral300));
      }
      out.add(item);
    }

    push(
      _item(
        value: MemberProjectMenuAction.projectFundsHistory,
        iconPath: AppAssets.memberFundsHistory,
        label: AppStrings.menuProjectFundsHistory,
        iconColor: AppColors.primary,
        labelColor: AppColors.grey900,
      ),
    );
    if (includeMyBorrows) {
      push(
        _item(
          value: MemberProjectMenuAction.myBorrows,
          iconPath: AppAssets.myBorrowsMenu,
          label: AppStrings.menuMyBorrows,
          iconColor: AppColors.primary,
          labelColor: AppColors.grey900,
        ),
      );
    }
    push(
      _item(
        value: MemberProjectMenuAction.inviteMembers,
        iconPath: AppAssets.iconAdd,
        label: AppStrings.menuInviteMembers,
        iconColor: AppColors.primary,
        labelColor: AppColors.grey900,
      ),
    );
    push(
      _item(
        value: MemberProjectMenuAction.leaveProject,
        iconPath: AppAssets.memberLeaveProject,
        label: AppStrings.menuLeaveProject,
        iconColor: AppColors.red900,
        labelColor: AppColors.red900,
      ),
    );

    return out;
  }

  PopupMenuItem<MemberProjectMenuAction> _item({
    required MemberProjectMenuAction value,
    required String iconPath,
    required String label,
    required Color iconColor,
    required Color labelColor,
  }) {
    return PopupMenuItem<MemberProjectMenuAction>(
      value: value,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
      child: Row(
        children: [
          SvgPicture.asset(
            iconPath,
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
}
