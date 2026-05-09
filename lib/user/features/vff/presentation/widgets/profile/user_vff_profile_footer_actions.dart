import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/core/widgets/common/app_svg_icon.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/user/features/vff/presentation/cubit/user_vff_profile_footer_cubit.dart';
import 'package:vestie/user/features/vff/presentation/models/user_vff_profile_ui_model.dart';
import 'package:vestie/user/features/vff/presentation/widgets/user_vff_remove_connection_dialog.dart';

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
      return PopupMenuButton<String>(
        offset: Offset(0, AppDimens.v48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
        ),
        itemBuilder: (_) => [
          PopupMenuItem(
            value: 'rm',
            child: AppText(
              AppStrings.userVffMenuRemoveConnection,
              style: GoogleFonts.lato(fontWeight: FontWeight.w700),
            ),
          ),
        ],
        onSelected: (v) async {
          if (v != 'rm') return;
          final ok = await showUserVffRemoveConnectionDialog(
            context,
            usernameWithoutAt: profile.usernameHandle,
          );
          if (!context.mounted) return;
          if (ok == true) {
            context.pop();
          }
        },
        child: SizedBox(
          width: double.infinity,
          height: 54.h,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.purple100,
              borderRadius: BorderRadius.circular(999.r),
              border: Border.all(color: AppColors.purple300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppText(
                  AppStrings.userVffFollowing,
                  style: GoogleFonts.lato(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryDark,
                  ),
                ),
                SizedBox(width: AppDimens.p8),
                AppSvgIcon(
                  assetPath: AppAssets.iconChevronDown,
                  color: AppColors.primaryDark,
                  size: 22.r,
                ),
              ],
            ),
          ),
        ),
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
