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
import 'package:vestie/features/project_detail/presentation/navigation/open_project_from_card.dart';
import 'package:vestie/user/features/vff/presentation/models/user_vff_profile_ui_types.dart';
import 'package:vestie/user/features/vff/presentation/cubit/user_vff_profile_cubit.dart';
import 'package:vestie/user/features/vff/presentation/cubit/user_vff_profile_state.dart';
import '../../models/user_vff_profile_ui_model.dart';
import '../user_vff_joined_project_row.dart';
import 'user_vff_profile_connected_header.dart';
import 'user_vff_profile_connected_metrics.dart';
import 'user_vff_profile_footer_actions.dart';

/// Connected VFF peer profile — hero + metrics on [UserVffProfileBackground] only.
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
            top: AppDimens.v8,
            bottom: AppDimens.v92,
          ),
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(AppDimens.p18, 0, AppDimens.p18, 8.h),
              child: UserVffProfileConnectedHeader(profile: profile),
            ),
            Padding(
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
                      (row) => BlocSelector<UserVffProfileCubit,
                          UserVffProfileState, bool>(
                        selector: (state) => state.isJoiningProject(row.projectId),
                        builder: (context, isJoining) {
                          return UserVffJoinedProjectRow(
                            row: row,
                            isLoading: isJoining,
                            onCardTap: _canOpenProjectDetail(row)
                                ? () => _openProjectDetail(context, row)
                                : null,
                            onJoin: _canJoinFromProfile(row, isJoining)
                                ? () => _onJoinProject(context, cubit, row)
                                : null,
                            onRequestJoin: _canRequestJoinFromProfile(row, isJoining)
                                ? () => _onJoinProject(context, cubit, row)
                                : null,
                          );
                        },
                      ),
                    ),
                  ],
                ],
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

  /// `joinState: AlreadyMember` → open `GET /projects/{id}` on card tap.
  static bool _canOpenProjectDetail(UserVffJoinedProjectRowUi row) {
    return row.projectId.isNotEmpty &&
        row.action == UserVffJoinedProjectAction.joined;
  }

  /// `joinState: Join` → primary Join chip.
  static bool _canJoinFromProfile(
    UserVffJoinedProjectRowUi row,
    bool isJoining,
  ) {
    return !isJoining &&
        row.projectId.isNotEmpty &&
        row.action == UserVffJoinedProjectAction.join;
  }

  /// `joinState: RequestToJoin` → Request to Join chip.
  static bool _canRequestJoinFromProfile(
    UserVffJoinedProjectRowUi row,
    bool isJoining,
  ) {
    return !isJoining &&
        row.projectId.isNotEmpty &&
        row.action == UserVffJoinedProjectAction.requestToJoin;
  }

  static void _openProjectDetail(
    BuildContext context,
    UserVffJoinedProjectRowUi row,
  ) {
    openProjectDetailById(
      context,
      projectId: row.projectId,
      isInvestment: row.isInvestment,
      initialProjectName: row.title,
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
