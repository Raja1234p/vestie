import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/presentation/paginated_scroll_listener.dart';
import 'package:vestie/core/presentation/widgets/list_load_more_footer.dart';
import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/app/router/route_args/user_vff_flow_args.dart';

import '../../constants/app_assets.dart';
import '../../constants/app_dimens.dart';
import '../../constants/app_strings.dart';
import '../../theme/app_colors.dart';
import 'app_toast.dart';
import '../../utils/invite_share_utils.dart';
import '../text/app_text.dart';
import 'app_network_avatar.dart';
import 'app_button.dart';
import 'app_invite_members_dashed_divider.dart';
import 'invite_vff_pick_ui.dart';
import 'package:vestie/user/features/vff/presentation/cubit/invite_members_sheet_cubit.dart';
import 'package:vestie/user/features/vff/presentation/cubit/invite_members_sheet_state.dart';
import 'package:vestie/user/features/vff/presentation/widgets/user_vff_shimmers.dart';

class AppInviteMembersBottomSheet extends StatefulWidget {
  final String projectId;
  final String projectName;
  final String inviteLink;

  const AppInviteMembersBottomSheet({
    super.key,
    required this.projectId,
    required this.projectName,
    required this.inviteLink,
  });

  @override
  State<AppInviteMembersBottomSheet> createState() =>
      _AppInviteMembersBottomSheetState();
}

class _AppInviteMembersBottomSheetState
    extends State<AppInviteMembersBottomSheet> {
  final Set<String> _selectedIds = {};
  final ScrollController _scrollController = ScrollController();
  PaginatedScrollListener? _scrollListener;

  @override
  void initState() {
    super.initState();
    _scrollListener = PaginatedScrollListener(
      controller: _scrollController,
      onLoadMore: () => context.read<InviteMembersSheetCubit>().loadMore(),
    );
  }

  @override
  void dispose() {
    _scrollListener?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

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
    AppToast.showError(context, AppStrings.errorGeneric);
  }

  void _openShareFromButton(BuildContext buttonContext) {
    final box = buttonContext.findRenderObject() as RenderBox?;
    final origin = box != null
        ? box.localToGlobal(Offset.zero) & box.size
        : null;
    _openShareSheet(buttonContext, origin: origin);
  }

  Future<void> _submitInvite(BuildContext context) async {
    final ids = _selectedIds.toList(growable: false);
    if (ids.isEmpty) return;

    final count = await context.read<InviteMembersSheetCubit>().inviteSelected(
      projectId: widget.projectId,
      userIds: ids,
    );
    if (!context.mounted || count == null) return;

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
    return BlocConsumer<InviteMembersSheetCubit, InviteMembersSheetState>(
      listenWhen: (prev, curr) =>
          prev.errorMessage != curr.errorMessage && curr.errorMessage != null,
      listener: (context, state) {
        final message = state.errorMessage;
        if (message == null || message.isEmpty) return;
        AppToast.showError(context, message);
      },
      builder: (context, sheetState) {
        final vffs = sheetState.vffs;
        final media = MediaQuery.of(context);
        final viewPadding = media.viewPadding;
        final maxBodyHeight =
            (media.size.height - viewPadding.top - viewPadding.bottom) * 0.88;
        final selectionCount = _selectedIds.length;
        final hasSelection = selectionCount > 0;
        final dividerGutter = AppDimens.inviteMembersDividerGutter;
        final hintToTopDivider = AppDimens.inviteMembersHintToDivider;
        final sheetContentInset = AppDimens.p20;
        final isSubmitting = sheetState.isSubmitting;

        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxBodyHeight),
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
              SizedBox(height: hintToTopDivider),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: sheetContentInset),
                child: const AppInviteMembersDashedDivider(),
              ),
              SizedBox(height: dividerGutter),
              Flexible(
                fit: FlexFit.loose,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: _buildVffGrid(
                    sheetState: sheetState,
                    vffs: vffs,
                    sheetContentInset: sheetContentInset,
                  ),
                ),
              ),
              if (hasSelection) ...[
                SizedBox(height: dividerGutter),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: sheetContentInset),
                  child: AppButton(
                    text: AppStrings.inviteMembersInviteSelected(
                      selectionCount,
                    ),
                    onPressed: isSubmitting
                        ? null
                        : () => _submitInvite(context),
                    isLoading: isSubmitting,
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
              SizedBox(
                height:
                    AppDimens.inviteMembersSheetBottom +
                    MediaQuery.viewInsetsOf(context).bottom,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVffGrid({
    required InviteMembersSheetState sheetState,
    required List<InviteVffPickUi> vffs,
    required double sheetContentInset,
  }) {
    if (sheetState.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: UserVffInviteGridShimmer(),
      );
    }

    if (sheetState.status == InviteMembersSheetLoadStatus.error) {
      return Padding(
        padding: EdgeInsets.symmetric(
          vertical: 24.h,
          horizontal: sheetContentInset,
        ),
        child: Column(
          children: [
            AppText(
              sheetState.errorMessage ?? AppStrings.errorGeneric,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 14.sp,
                color: AppColors.grey700,
              ),
            ),
            SizedBox(height: 12.h),
            TextButton(
              onPressed: () =>
                  context.read<InviteMembersSheetCubit>().retryLoad(),
              child: AppText(AppStrings.btnRetry),
            ),
          ],
        ),
      );
    }

    if (vffs.isEmpty) {
      final message = sheetState.allConnectionsAlreadyInProject
          ? AppStrings.inviteMembersAllVffsInProject
          : AppStrings.userVffEmptyMyVffs;
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 24.h),
        child: AppText(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.lato(fontSize: 14.sp, color: AppColors.grey700),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: sheetContentInset),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 12.h,
            crossAxisSpacing: 34.w,
            mainAxisExtent: 88.h,
          ),
          itemCount: vffs.length,
          itemBuilder: (_, i) {
            final vff = vffs[i];
            final selected = _selectedIds.contains(vff.id);
            return _VffGridTile(
              vff: vff,
              selected: selected,
              onTap: () => _toggleVff(vff.id),
            );
          },
        ),
        ListLoadMoreFooter(loadingMore: sheetState.loadingMore),
      ],
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
    return LayoutBuilder(
      builder: (context, constraints) {
        // Grid cell width can be < 60.w — keep avatar square (circle).
        final avatarSide = math.min(60.r, constraints.maxWidth);
        final badgeSize = 16.r;
        final borderWidth = 3.r;

        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: avatarSide,
                height: avatarSide,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AppNetworkAvatar(
                      imageUrl: vff.photoUrl,
                      initials: vff.initials,
                      size: avatarSide,
                      backgroundColor: AppColors.purple300.withValues(
                        alpha: 0.45,
                      ),
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
                          AppAssets.vffFriendSelected,
                          width: badgeSize,
                          height: badgeSize,
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 4.h),
              SizedBox(
                width: avatarSide,
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
      },
    );
  }
}
