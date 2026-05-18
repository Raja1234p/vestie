import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_strings.dart';
import '../../theme/app_colors.dart';
import 'app_invite_members_bottom_sheet.dart';
import 'invite_vff_pick_ui.dart';

/// Invite members — modal bottom sheet (VFF grid + share row).
class AppInviteMembersDialog {
  AppInviteMembersDialog._();

  static Future<void> show(
    BuildContext context, {
    required String projectName,
    String inviteLink = AppStrings.inviteLinkSample,
    List<InviteVffPickUi>? vffs,
  }) {
    final pickList = vffs ?? _previewVffs();

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 0),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  blurRadius: 24,
                  offset: const Offset(0, -6),
                  color: Colors.black.withValues(alpha: 0.08),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              bottom: false,
              minimum: EdgeInsets.zero,
              child: AppInviteMembersBottomSheet(
                projectName: projectName,
                inviteLink: inviteLink,
                vffs: pickList,
              ),
            ),
          ),
        );
      },
    );
  }

  /// Placeholder VFF rows until project-invite picker API is wired.
  static List<InviteVffPickUi> previewVffsPlaceholder() {
    return List.generate(
      12,
      (i) => InviteVffPickUi(
        id: 'preview-vff-$i',
        name: 'Olivia',
        initials: 'O',
      ),
    );
  }

  static List<InviteVffPickUi> _previewVffs() => previewVffsPlaceholder();
}
