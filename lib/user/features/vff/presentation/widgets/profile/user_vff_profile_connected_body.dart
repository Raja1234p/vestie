import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/app/router/route_args/user_vff_flow_args.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/user/features/vff/presentation/cubit/user_vff_profile_cubit.dart';
import '../../models/user_vff_profile_ui_model.dart';
import '../user_vff_joined_project_row.dart';
import 'user_vff_profile_connected_header.dart';
import 'user_vff_profile_connected_metrics.dart';
import 'user_vff_profile_footer_actions.dart';

/// Connected VFF peer profile — Figma: hero on gradient, white body below.
final class UserVffProfileConnectedBody extends StatelessWidget {
  final UserVffProfileUiModel profile;

  const UserVffProfileConnectedBody({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<UserVffProfileCubit>();
    final joinedList = profile.joinedProjects ?? const <UserVffJoinedProjectRowUi>[];

    return Stack(
      children: [
        ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(
            top: AppDimens.v48,
            bottom: AppDimens.v92,
          ),
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(AppDimens.p18, 0, AppDimens.p18, 8.h),
              child: UserVffProfileConnectedHeader(profile: profile),
            ),
            ColoredBox(
              color: AppColors.surface,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppDimens.p18,
                  12.h,
                  AppDimens.p18,
                  AppDimens.v20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    UserVffProfileConnectedMetrics(profile: profile),
                    if (joinedList.isNotEmpty) ...[
                      SizedBox(height: 20.h),
                      AppText(
                        AppStrings.joinedProjects,
                        style: GoogleFonts.lato(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.grey1100,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      ...joinedList.map(
                        (row) => UserVffJoinedProjectRow(
                          row: row,
                          onJoin: row.projectId.isEmpty
                              ? null
                              : () => _onJoinProject(context, cubit, row),
                          onRequestJoin: row.projectId.isEmpty
                              ? null
                              : () => _onJoinProject(context, cubit, row),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppDimens.p18,
                0,
                AppDimens.p18,
                8.h,
              ),
              child: const UserVffProfileFooterActions(),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _onJoinProject(
    BuildContext context,
    UserVffProfileCubit cubit,
    UserVffJoinedProjectRowUi row,
  ) async {
    final ok = await cubit.joinFromVff(row.projectId);
    if (!context.mounted || !ok) return;
    context.push(
      AppRoutes.userVffInvitesSent,
      extra: UserVffInvitesSentRouteArgs(
        inviteCount: 1,
        projectName: row.title,
      ),
    );
  }
}
