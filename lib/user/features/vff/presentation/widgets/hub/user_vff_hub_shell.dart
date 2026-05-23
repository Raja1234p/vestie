import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/common/app_toggle_tab_bar.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/common/post_auth_header.dart';
import '../../cubit/user_vff_hub_cubit.dart';
import '../../cubit/user_vff_hub_state.dart';
import '../user_vff_rounded_sheet.dart';
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
                fontSize: 20.sp,
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
                      AppDimens.v24,
                      AppDimens.p16,
                      0,
                    ),
                    child: BlocSelector<UserVffHubCubit, UserVffHubState, int>(
                      selector: (s) => s.tabIndex,
                      builder: (context, idx) => AppToggleTabBar(
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
                        activeIndex: idx,
                        onTabSelected: (i) =>
                            context.read<UserVffHubCubit>().selectTab(i),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Expanded(
                    child: BlocBuilder<UserVffHubCubit, UserVffHubState>(
                      builder: (context, hubState) {
                        if (hubState.tabIndex == 0) {
                          return UserVffHubMyVffsTab(hubState: hubState);
                        }
                        return UserVffHubRequestsTab(hubState: hubState);
                      },
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
}
