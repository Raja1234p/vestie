import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/app/router/route_args/user_vff_flow_args.dart';

import '../../constants/app_assets.dart';
import '../../constants/app_dimens.dart';
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

  void _submitInvite(BuildContext context) {
    final count = _selectedIds.length;
    if (count == 0) return;
    final args = UserVffInvitesSentRouteArgs(
      inviteCount: count,
      projectName: widget.projectName,
    );
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    router.push(AppRoutes.userVffInvitesSent, extra: args);
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.88;
    final selectionCount = _selectedIds.length;
    final hasSelection = selectionCount > 0;
    final dividerGutter = AppDimens.inviteMembersDividerGutter;
    final sheetContentInset = AppDimens.p20;

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
                color: AppColors.neutral700,
              ),
            ),
          ),
          SizedBox(height: dividerGutter),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: sheetContentInset),
            child: const AppInviteMembersDashedDivider(),
          ),
          SizedBox(height: dividerGutter),
          Flexible(
            fit: FlexFit.loose,
            child: SingleChildScrollView(
              child: widget.vffs.isEmpty
                  ? Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.h),
                      child: AppText(
                        AppStrings.userVffEmptyMyVffs,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(
                          fontSize: 14.sp,
                          color: AppColors.grey700,
                        ),
                      ),
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: sheetContentInset),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 12.h,
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
          ),
          if (hasSelection) ...[
            SizedBox(height: dividerGutter),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: sheetContentInset),
              child: AppButton(
                text: AppStrings.inviteMembersInviteSelected(selectionCount),
                onPressed: () => _submitInvite(context),
                useGradient: false,
                hasShadow: false,
                color: AppColors.purple800,
                borderRadius: 10.r,
                height: 50.h,
              ),
            ),
          ],
          SizedBox(height: dividerGutter),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: sheetContentInset),
            child: const AppInviteMembersDashedDivider(),
          ),
          SizedBox(height: dividerGutter),
          AppText(
            AppStrings.inviteMembersOrShareVia,
            style: GoogleFonts.lato(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.neutral700,
            ),
          ),
          SizedBox(height: dividerGutter),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: sheetContentInset),
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
    final avatarSize = 60.w;
    final badgeSize = 16.w;
    final borderWidth = 3.w;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: avatarSize,
            height: avatarSize,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                AppAvatarCircle(
                  initials: vff.initials,
                  size: avatarSize,
                  backgroundColor:
                      AppColors.purple300.withValues(alpha: 0.45),
                  textColor: AppColors.grey1100,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                ),
                if (selected)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.purple900,
                            width: borderWidth,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (selected)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: SvgPicture.asset(
                      AppAssets.iconFriendSelected,
                      width: badgeSize,
                      height: badgeSize,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 4.h),
          SizedBox(
            width: avatarSize,
            child: AppText(
              vff.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.grey1100,
                height: 1.15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

