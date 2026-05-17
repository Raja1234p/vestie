import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/app_strings.dart';
import '../../theme/app_colors.dart';
import '../../utils/app_snackbar.dart';
import '../../utils/invite_share_utils.dart';
import '../text/app_text.dart';
import 'app_avatar_circle.dart';
import 'app_button.dart';
import 'app_invite_members_dashed_divider.dart';
import 'invite_vff_pick_ui.dart';

class AppInviteMembersBottomSheet extends StatefulWidget {
  final String projectName;
  final String inviteLink;
  final List<InviteVffPickUi> vffs;

  const AppInviteMembersBottomSheet({
    super.key,
    required this.projectName,
    required this.inviteLink,
    required this.vffs,
  });

  @override
  State<AppInviteMembersBottomSheet> createState() =>
      _AppInviteMembersBottomSheetState();
}

class _AppInviteMembersBottomSheetState
    extends State<AppInviteMembersBottomSheet> {
  final Set<String> _selectedIds = {};

  void _toggleVff(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  Future<void> _openShareSheet(BuildContext context, {Rect? origin}) async {
    final ok = await openInviteShareSheet(
      inviteLink: widget.inviteLink,
      projectName: widget.projectName,
      sharePositionOrigin: origin,
    );
    if (!context.mounted || ok) return;
    AppSnackBar.showError(context, AppStrings.errorGeneric);
  }

  void _openShareFromButton(BuildContext buttonContext) {
    final box = buttonContext.findRenderObject() as RenderBox?;
    final origin = box != null
        ? box.localToGlobal(Offset.zero) & box.size
        : null;
    _openShareSheet(buttonContext, origin: origin);
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.88;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 24.h),
          Container(
            width: 52.w,
            height: 5.h,
            decoration: BoxDecoration(
              color: AppColors.neutral400,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: AppText(
              AppStrings.inviteMembersTitle(widget.projectName),
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.grey1100,
              ),
            ),
          ),
          SizedBox(height: 6.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: AppText(
              AppStrings.inviteMembersSelectVffHint,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.grey700,
              ),
            ),
          ),
          SizedBox(height: 14.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: const AppInviteMembersDashedDivider(),
          ),
          SizedBox(height: 12.h),
          Flexible(
            fit: FlexFit.loose,
            child: widget.vffs.isEmpty
                ? Center(
                    child: AppText(
                      AppStrings.userVffEmptyMyVffs,
                      style: GoogleFonts.lato(
                        fontSize: 14.sp,
                        color: AppColors.grey700,
                      ),
                    ),
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 20.h,
                      crossAxisSpacing: 34.w,
                      mainAxisExtent: 88.h,
                    ),
                    itemCount: widget.vffs.length,
                    itemBuilder: (_, i) {
                      final vff = widget.vffs[i];
                      final selected = _selectedIds.contains(vff.id);
                      return _VffGridTile(
                        vff: vff,
                        selected: selected,
                        onTap: () => _toggleVff(vff.id),
                      );
                    },
                  ),
          ),
          SizedBox(height: 24.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: const AppInviteMembersDashedDivider(),
          ),
          SizedBox(height: 12.h),
          AppText(
            AppStrings.inviteMembersOrShareVia,
            style: GoogleFonts.lato(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.neutral700,
            ),
          ),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Builder(
              builder: (buttonContext) {
                return AppButton(
                  text: AppStrings.inviteShareOutsideVestie,
                  onPressed: () => _openShareFromButton(buttonContext),
                  useGradient: false,
                  hasShadow: false,
                  color: AppColors.neutral1200,
                  borderRadius: 10.r,
                  height: 50.h,
                );
              },
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}

class _VffGridTile extends StatelessWidget {
  final InviteVffPickUi vff;
  final bool selected;
  final VoidCallback onTap;

  const _VffGridTile({
    required this.vff,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(selected ? 3.w : 0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: selected
                  ? Border.all(color: AppColors.primary, width: 2.w)
                  : null,
            ),
            child: AppAvatarCircle(
              initials: vff.initials,
              size: 60.w,
              backgroundColor: AppColors.purple300.withValues(alpha: 0.45),
              textColor: AppColors.grey1100,
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6.h),
          AppText(
            vff.displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.grey1100,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

