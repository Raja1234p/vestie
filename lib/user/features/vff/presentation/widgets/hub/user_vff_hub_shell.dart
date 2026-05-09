import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_durations.dart';
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

/// Gradient scaffold wrapping VFF hub tabs + sheet.
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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppDimens.p16),
              child: BlocSelector<UserVffHubCubit, UserVffHubState, int>(
                selector: (s) => s.tabIndex,
                builder: (context, idx) => AppToggleTabBar(
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
            SizedBox(height: AppDimens.v10),
            Expanded(
              child: UserVffRoundedSheet(
                padding: AppDimens.sheetInsetComfort,
                child: BlocBuilder<UserVffHubCubit, UserVffHubState>(
                  builder: (context, hubState) {
                    return AnimatedSwitcher(
                      duration: AppDurations.hubTabFade,
                      child: hubState.tabIndex == 0
                          ? KeyedSubtree(
                              key: const ValueKey('vff-my'),
                              child: UserVffHubMyVffsTab(
                                hubState: hubState,
                              ),
                            )
                          : KeyedSubtree(
                              key: const ValueKey('vff-requests'),
                              child: UserVffHubRequestsTab(
                                hubState: hubState,
                              ),
                            ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
