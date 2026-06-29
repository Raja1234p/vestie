import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/presentation/widgets/list_load_more_footer.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/flow_screen_footer.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/features/project_detail/presentation/navigation/open_project_from_card.dart';
import 'package:vestie/user/features/vff/presentation/cubit/user_vff_profile_cubit.dart';
import 'package:vestie/user/features/vff/presentation/cubit/user_vff_profile_state.dart';
import '../../models/user_vff_profile_ui_model.dart';
import '../user_vff_joined_project_row.dart';
import 'user_vff_profile_connected_header.dart';
import 'user_vff_profile_connected_metrics.dart';
import 'user_vff_profile_footer_actions.dart';

/// Connected VFF peer profile — hero + metrics over screen background image.
final class UserVffProfileConnectedBody extends StatefulWidget {
  final UserVffProfileUiModel profile;

  const UserVffProfileConnectedBody({super.key, required this.profile});

  @override
  State<UserVffProfileConnectedBody> createState() =>
      _UserVffProfileConnectedBodyState();
}

class _UserVffProfileConnectedBodyState
    extends State<UserVffProfileConnectedBody> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    final offset = _scrollController.offset;
    if (max - offset <= 200) {
      context.read<UserVffProfileCubit>().loadMoreJoinedProjects();
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final cubit = context.read<UserVffProfileCubit>();
    final joinedList =
        profile.joinedProjects ?? const <UserVffJoinedProjectRowUi>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(top: AppDimens.v8, bottom: AppDimens.v20),
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppDimens.p18,
                  0,
                  AppDimens.p18,
                  8.h,
                ),
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
                        (row) =>
                            BlocSelector<
                              UserVffProfileCubit,
                              UserVffProfileState,
                              bool
                            >(
                              selector: (state) =>
                                  state.isJoiningProject(row.projectId),
                              builder: (context, isJoining) {
                                return UserVffJoinedProjectRow(
                                  row: row,
                                  isLoading: isJoining,
                                  onCardTap: _canOpenProjectDetail(row)
                                      ? () => _openProjectDetail(context, row)
                                      : null,
                                  onJoin: _canJoinFromProfile(row, isJoining)
                                      ? () =>
                                            _onJoinProject(context, cubit, row)
                                      : null,
                                  onRequestJoin:
                                      _canRequestJoinFromProfile(row, isJoining)
                                      ? () =>
                                            _onJoinProject(context, cubit, row)
                                      : null,
                                );
                              },
                            ),
                      ),
                      BlocSelector<UserVffProfileCubit, UserVffProfileState, bool>(
                        selector: (state) => state.joinedProjectsLoadingMore,
                        builder: (context, loadingMore) =>
                            ListLoadMoreFooter(loadingMore: loadingMore),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const FlowScreenFooter(child: UserVffProfileFooterActions()),
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

    if (row.action == UserVffJoinedProjectAction.requestToJoin) {
      openProjectJoinRequestSentSuccess(
        context,
        projectId: row.projectId,
        projectName: row.title,
        isInvestment: row.isInvestment,
      );
      return;
    }

    openProjectJoinedSuccess(
      context,
      projectId: row.projectId,
      projectName: row.title,
      isInvestment: row.isInvestment,
    );
  }
}
