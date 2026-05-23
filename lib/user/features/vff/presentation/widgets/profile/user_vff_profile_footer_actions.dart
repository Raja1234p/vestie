import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/user/features/vff/presentation/cubit/user_vff_profile_footer_cubit.dart';
import 'package:vestie/user/features/vff/presentation/models/user_vff_profile_ui_model.dart';
import 'package:vestie/user/features/vff/presentation/widgets/user_vff_remove_connection_dialog.dart';
import 'package:vestie/user/features/vff/presentation/widgets/vff_following_menu_button.dart';

/// Sticky footer: Following menu, Sent chip, or primary CTA.
final class UserVffProfileFooterActions extends StatelessWidget {
  final UserVffProfileUiModel profile;

  const UserVffProfileFooterActions({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final footerCubit = context.watch<UserVffProfileFooterCubit>();
    final isFollowingUi =
        profile.footerMode == UserVffProfileFooterMode.followingSheet;
    final sent = footerCubit.showsRequestSentRibbon(profile);

    if (isFollowingUi) {
      return VffFollowingMenuButton(
        onRemove: () async {
          final ok = await showUserVffRemoveConnectionDialog(
            context,
            usernameWithoutAt: profile.usernameHandle,
          );
          if (!context.mounted) return;
          if (ok == true) {
            context.pop();
          }
        },
      );
    }

    if (sent) {
      return AppButton(
        text: AppStrings.btnVffRequestSent,
        onPressed: null,
        isSecondary: true,
      );
    }

    return AppButton(
      text: AppStrings.btnSendVffRequest,
      useGradient: false,
      color: AppColors.grey1200,
      hasShadow: true,
      onPressed: () =>
          context.read<UserVffProfileFooterCubit>().markRequestSent(),
    );
  }
}
