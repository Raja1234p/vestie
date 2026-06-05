import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/utils/app_snackbar.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/common/app_toggle_tab_bar.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/common/post_auth_header.dart';
import '../../cubit/user_vff_hub_cubit.dart';
import '../../cubit/user_vff_hub_state.dart';
import '../user_vff_inbox_interaction_lock.dart';
import '../user_vff_shimmers.dart';
import 'user_vff_hub_my_vffs_tab.dart';
import 'user_vff_hub_requests_tab.dart';

/// Gradient header + single white sheet (tabs + tab body — Figma).
final class UserVffHubShell extends StatelessWidget {
  const UserVffHubShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PostAuthGradientBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PostAuthHeader(
              title: AppStrings.userVffHubTitle,
              leading: AppBackButton(onPressed: () => context.pop()),
              titleStyle: GoogleFonts.lato(
                fontSize: 28.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.grey1100,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppDimens.p16,
                      AppDimens.v12,
                      AppDimens.p16,
                      0,
                    ),
                    child: BlocSelector<UserVffHubCubit, UserVffHubState,
                        ({int tabIndex, bool inboxBusy})>(
                      selector: (s) =>
                          (tabIndex: s.tabIndex, inboxBusy: s.isInboxActionBusy),
                      builder: (context, data) => IgnorePointer(
                        ignoring: data.inboxBusy,
                        child: AppToggleTabBar(
                          outerHeight:
                              AppDimens.projectDetailToggleBarOuterHeight,
                          innerTabHeight:
                              AppDimens.projectDetailToggleTabInnerHeight,
                          outerBorderRadius:
                              AppDimens.projectDetailToggleBarOuterRadius,
                          innerBorderRadius:
                              AppDimens.projectDetailToggleTabInnerRadius,
                          labelFontSize:
                              AppDimens.projectDetailToggleLabelFontSize,
                          labelFontWeight: FontWeight.w500,
                          activeLabelColor: AppColors.surface,
                          inactiveLabelColor: AppColors.grey1100,
                          tabs: const [
                            AppStrings.userVffTabMyVffs,
                            AppStrings.userVffTabRequests,
                          ],
                          activeIndex: data.tabIndex,
                          onTabSelected: data.inboxBusy
                              ? (_) {}
                              : (i) => context
                                  .read<UserVffHubCubit>()
                                  .selectTab(i),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Expanded(
                    child: BlocSelector<UserVffHubCubit, UserVffHubState, bool>(
                      selector: (s) => s.isInboxActionBusy,
                      builder: (context, inboxBusy) =>
                          UserVffInboxInteractionLock(
                        locked: inboxBusy,
                        child: BlocConsumer<UserVffHubCubit, UserVffHubState>(
                          listenWhen: (prev, curr) {
                            final err = curr.errorMessage;
                            final reqErr = curr.requestsErrorMessage;
                            return (prev.errorMessage != err && err != null) ||
                                (prev.requestsErrorMessage != reqErr &&
                                    reqErr != null);
                          },
                          listener: (context, hubState) {
                            final message = hubState.errorMessage ??
                                hubState.requestsErrorMessage;
                            if (message == null || message.isEmpty) return;
                            AppSnackBar.showError(context, message);
                          },
                          builder: (context, hubState) {
                            if (hubState.tabIndex == 0) {
                              return _buildMyVffsBody(context, hubState);
                            }
                            return _buildRequestsBody(context, hubState);
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyVffsBody(BuildContext context, UserVffHubState hubState) {
    if (hubState.loadStatus == UserVffHubLoadStatus.loading &&
        hubState.myVffConnections.isEmpty) {
      return const UserVffHubShimmer(requestsTab: false);
    }
    if (hubState.loadStatus == UserVffHubLoadStatus.error &&
        hubState.myVffConnections.isEmpty) {
      return _HubErrorBody(
        message: hubState.errorMessage ?? AppStrings.errorGeneric,
        onRetry: () => context.read<UserVffHubCubit>().load(),
      );
    }
    return UserVffHubMyVffsTab(hubState: hubState);
  }

  Widget _buildRequestsBody(BuildContext context, UserVffHubState hubState) {
    final loading = hubState.requestsLoadStatus ==
            UserVffHubRequestsLoadStatus.loading ||
        hubState.requestsLoadStatus == UserVffHubRequestsLoadStatus.initial;

    if (loading &&
        hubState.incomingVffRequests.isEmpty &&
        hubState.groupInvitations.isEmpty) {
      return const UserVffHubShimmer(requestsTab: true);
    }
    if (hubState.requestsLoadStatus == UserVffHubRequestsLoadStatus.error &&
        hubState.incomingVffRequests.isEmpty &&
        hubState.groupInvitations.isEmpty) {
      return _HubErrorBody(
        message: hubState.requestsErrorMessage ?? AppStrings.errorGeneric,
        onRetry: () =>
            context.read<UserVffHubCubit>().loadReceivedInbox(force: true),
      );
    }
    return UserVffHubRequestsTab(hubState: hubState);
  }
}

class _HubErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _HubErrorBody({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppDimens.p18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText(message, textAlign: TextAlign.center),
            SizedBox(height: 16.h),
            TextButton(
              onPressed: onRetry,
              child: AppText(AppStrings.btnRetry),
            ),
          ],
        ),
      ),
    );
  }
}
