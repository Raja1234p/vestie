import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/route_args/user_vff_flow_args.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/user/features/vff/presentation/cubit/user_vff_profile_cubit.dart';
import 'package:vestie/user/features/vff/presentation/cubit/user_vff_profile_state.dart';
import 'package:vestie/user/features/vff/presentation/models/user_vff_profile_ui_model.dart';
import 'package:vestie/user/features/vff/presentation/widgets/user_vff_remove_connection_dialog.dart';
import 'package:vestie/user/features/vff/presentation/widgets/vff_following_menu_button.dart';

/// Sticky footer: Following menu, Sent chip, or primary CTA.
final class UserVffProfileFooterActions extends StatelessWidget {
  const UserVffProfileFooterActions({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserVffProfileCubit, UserVffProfileState>(
      builder: (context, state) {
        final profile = state.profile;
        if (profile == null || !profile.showFooter) {
          return const SizedBox.shrink();
        }

        final cubit = context.read<UserVffProfileCubit>();
        final footerMode = state.effectiveFooterMode;
        final isFollowingUi =
            footerMode == UserVffProfileFooterMode.followingSheet;
        final sent = state.showsRequestSentRibbon;

        if (isFollowingUi) {
          return VffFollowingMenuButton(
            onRemove: state.isFooterBusy
                ? null
                : () async {
                    final removed = await showUserVffRemoveConnectionDialog(
                      context,
                      usernameWithoutAt: profile.usernameHandle,
                      onConfirm: cubit.removeVffConnection,
                    );
                    if (!context.mounted || !removed) return;
                    context.pop(UserVffProfilePopResult.connectionRemoved);
                  },
          );
        }

        if (sent) {
          return AppButton(
            text: AppStrings.btnVffRequestSent,
            onPressed: null,
            isSecondary: true,
            useGradient: false,
            hasShadow: false,
            borderRadius: AppRadius.vffHubRequestActionButton,
            secondaryFillColor: AppColors.vffRequestSentChipBg,
            secondaryBorderColor: AppColors.vffRequestSentChipBorder,
            secondaryLabelColor: AppColors.vffRequestSentChipLabel,
            secondaryLabelFontWeight: FontWeight.w600,
          );
        }

        return AppButton(
          text: AppStrings.btnSendVffRequest,
          useGradient: false,
          color: AppColors.grey1200,
          hasShadow: true,
          isLoading: state.isActionLoading,
          onPressed: state.isFooterBusy ? null : cubit.sendVffRequest,
        );
      },
    );
  }
}
