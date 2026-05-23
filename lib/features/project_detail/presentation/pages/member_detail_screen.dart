import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:go_router/go_router.dart';



import '../../../../app/router/app_routes.dart';
import '../../../../app/router/route_args/project_detail_flow_args.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/failures.dart';

import '../../../../core/di/service_locator.dart';

import '../../../../core/widgets/common/app_back_button.dart';

import '../../../../core/widgets/common/app_shimmer.dart';

import '../../../../core/widgets/common/post_auth_gradient_background.dart';

import '../../../../core/widgets/common/post_auth_header.dart';

import '../../domain/entities/member_activity_entity.dart';

import '../../domain/entities/member_entity.dart';

import '../../domain/entities/member_entity_extensions.dart';

import '../../domain/entities/project_detail_entity.dart';

import 'package:vestie/leader/features/project_detail/presentation/widgets/member_detail_actions.dart';

import 'package:vestie/leader/features/project_detail/presentation/widgets/member_detail_result_dialogs.dart';

import '../cubit/member_detail_cubit.dart';

import '../widgets/member_detail_actions_visibility.dart';

import '../widgets/member_detail_footer.dart';

import '../widgets/member_detail_sections.dart';

import '../widgets/project_detail_load_error.dart';



class MemberDetailScreen extends StatelessWidget {

  final MemberEntity member;

  final String projectId;

  final String projectName;

  final ProjectDetailEntity? project;

  final bool isLeaderView;

  final VoidCallback? onProjectMembersChanged;



  const MemberDetailScreen({

    super.key,

    required this.member,

    required this.projectId,

    required this.projectName,

    this.project,

    this.isLeaderView = false,

    this.onProjectMembersChanged,

  });



  @override

  Widget build(BuildContext context) {

    return BlocProvider(

      create: (_) => MemberDetailCubit(

        getMemberActivityUseCase: ServiceLocator.instance.getMemberActivityUseCase,

        updateCoLeaderRoleUseCase: ServiceLocator.instance.updateCoLeaderRoleUseCase,

        removeMemberUseCase: ServiceLocator.instance.removeMemberUseCase,

      )..load(

          projectId: projectId,

          userId: member.apiUserId,

          projectName: projectName,

        ),

      child: _MemberDetailView(

        member: member,

        projectId: projectId,

        projectName: projectName,

        project: project,

        isLeaderView: isLeaderView,

        onProjectMembersChanged: onProjectMembersChanged,

      ),

    );

  }

}



class _MemberDetailView extends StatelessWidget {

  const _MemberDetailView({

    required this.member,

    required this.projectId,

    required this.projectName,

    required this.project,

    required this.isLeaderView,

    this.onProjectMembersChanged,

  });



  final MemberEntity member;

  final String projectId;

  final String projectName;

  final ProjectDetailEntity? project;

  final bool isLeaderView;

  final VoidCallback? onProjectMembersChanged;



  String _userIdForApi(MemberDetailState state) {
    final resolved = _displayMember(state).apiUserId.trim();
    if (resolved.isNotEmpty) return resolved;
    return member.apiUserId.trim();
  }



  MemberEntity _displayMember(MemberDetailState state) {
    final loaded = state.activity?.member;
    if (loaded == null) return member;
    return member.mergedWithActivity(loaded);
  }



  void _onStateChanged(BuildContext context, MemberDetailState state) {

    if (state.isActionLoading) return;



    final failure = state.failure;

    if (failure != null) {

      showMemberDetailErrorDialog(
        context,
        failure: failure,
      );

      context.read<MemberDetailCubit>().clearStatus();

      return;

    }



    final completed = state.completedAction;

    if (completed == null) return;



    final displayName = _displayMember(state).name;



    switch (completed) {

      case MemberDetailAction.assignCoLeader:

      case MemberDetailAction.removeCoLeader:

        onProjectMembersChanged?.call();

        if (completed == MemberDetailAction.assignCoLeader) {
          showCoLeaderAssignedSuccess(
            context,
            memberName: displayName,
            projectName: projectName,
            onOk: () => Navigator.of(context).pop(),
          );
        } else {
          showCoLeaderRemovedSuccess(
            context,
            memberName: displayName,
            projectName: projectName,
            onOk: () => Navigator.of(context).pop(),
          );
        }
        break;

      case MemberDetailAction.removeMember:

        showMemberRemovedSuccess(

          context,

          onOk: () {

            Navigator.of(context).pop();

            context.pop(MemberDetailPopResult.memberRemoved);

          },

        );

    }



    context.read<MemberDetailCubit>().clearStatus();

  }



  void _promptAssignCoLeader(BuildContext context) {
    final p = project;
    if (p == null || !p.supportsCoLeader) return;

    final cubit = context.read<MemberDetailCubit>();
    final state = cubit.state;
    final memberName = _displayMember(state).name;
    final userId = _userIdForApi(state);

    showMakeCoLeaderConfirm(
      context,
      memberName: memberName,
      onConfirmed: () => cubit.assignCoLeader(
        projectId: projectId,
        userId: userId,
      ),
    );
  }



  void _promptRemoveCoLeader(BuildContext context) {
    final p = project;
    if (p == null || !p.supportsCoLeader) return;

    final cubit = context.read<MemberDetailCubit>();
    final state = cubit.state;
    final memberName = _displayMember(state).name;
    final userId = _userIdForApi(state);

    showRemoveCoLeaderConfirm(
      context,
      memberName: memberName,
      onConfirmed: () => cubit.removeCoLeader(
        projectId: projectId,
        userId: userId,
      ),
    );
  }



  Future<void> _openPenaltyAction(BuildContext context) async {
    final p = project;
    if (p == null) return;

    final outcome = await context.push<MemberPenaltyActionOutcome>(
      AppRoutes.memberPenaltyAction,
      extra: MemberPenaltyActionRouteArgs(
        member: _displayMember(context.read<MemberDetailCubit>().state),
        projectId: projectId,
        project: p,
      ),
    );

    if (!context.mounted || outcome == null) return;

    if (outcome == MemberPenaltyActionOutcome.memberRemoved) {
      context.pop(MemberDetailPopResult.memberRemoved);
      return;
    }

    final refreshed = await context.read<MemberDetailCubit>().refresh();
    if (!context.mounted) return;
    if (!refreshed) {
      showMemberDetailErrorDialog(
        context,
        failure: const ServerFailure(AppStrings.errorGeneric),
      );
    }
  }

  void _promptRemoveMember(BuildContext context) {

    showRemoveMemberConfirm(

      context,

      memberName: _displayMember(context.read<MemberDetailCubit>().state).name,

      onConfirmed: () {
        final userId = _userIdForApi(
          context.read<MemberDetailCubit>().state,
        );
        context.read<MemberDetailCubit>().removeMember(
          projectId: projectId,
          userId: userId,
        );
      },

    );

  }



  @override

  Widget build(BuildContext context) {

    final p = project;



    return BlocListener<MemberDetailCubit, MemberDetailState>(

      listenWhen: (prev, curr) =>

          prev.isActionLoading != curr.isActionLoading ||

          prev.failure != curr.failure ||

          prev.completedAction != curr.completedAction,

      listener: _onStateChanged,

      child: BlocBuilder<MemberDetailCubit, MemberDetailState>(

        builder: (context, state) {

          final displayMember = _displayMember(state);

          final activity = state.activity;

          final isCoLeader = activity?.isCoLeader ??
              displayMember.role == MemberRole.coLeader;



          final showCoLeaderControls = p != null &&

              MemberDetailActionsVisibility.showCoLeaderControls(

                project: p,

                member: displayMember,

              );

          final showSendVff = p != null &&

              MemberDetailActionsVisibility.showSendVffRequest(

                project: p,

                member: displayMember,

              );

          final showRemoveMember = p != null &&

              MemberDetailActionsVisibility.showRemoveMember(

                project: p,

                member: displayMember,

              );

          final showFooter = p != null &&

              MemberDetailActionsVisibility.showFooter(

                project: p,

                member: displayMember,

              );



          final coLeaderLoading = state.isLoadingAction(

                MemberDetailAction.assignCoLeader,

              ) ||

              state.isLoadingAction(MemberDetailAction.removeCoLeader);



          return Scaffold(

            backgroundColor: Colors.transparent,

            body: PostAuthGradientBackground(

              child: Column(

                crossAxisAlignment: CrossAxisAlignment.stretch,

                children: [

                  PostAuthHeader(

                    title:

                        '${displayMember.name}${AppStrings.memberProfileSuffix}',

                    leading: AppBackButton(

                      onPressed: () {
                        final changed = context
                            .read<MemberDetailCubit>()
                            .state
                            .projectMembersChanged;
                        context.pop(
                          changed
                              ? MemberDetailPopResult.membersUpdated
                              : null,
                        );
                      },

                    ),

                  ),

                  Expanded(

                    child: _buildBody(

                      context,

                      state: state,

                      activity: activity,

                      displayMember: displayMember,

                      project: p,

                      isCoLeader: isCoLeader,

                      showCoLeaderControls: showCoLeaderControls,

                      coLeaderLoading: coLeaderLoading,

                    ),

                  ),

                  if (showFooter && state.loadStatus == MemberDetailLoadStatus.loaded)

                    MemberDetailFooter(

                      showSendVffRequest: showSendVff,

                      vffRequestSent: state.vffRequestSent,

                      isVffRequestLoading: state.isVffRequestLoading,

                      showRemoveMember: showRemoveMember,

                      isRemoveMemberLoading: state.isLoadingAction(

                        MemberDetailAction.removeMember,

                      ),

                      onSendVffRequest: () => context

                          .read<MemberDetailCubit>()

                          .sendVffRequest(),

                      onRemoveMember: () => _promptRemoveMember(context),

                    ),

                ],

              ),

            ),

          );

        },

      ),

    );

  }



  Widget _buildBody(

    BuildContext context, {

    required MemberDetailState state,

    required MemberActivityEntity? activity,

    required MemberEntity displayMember,

    required ProjectDetailEntity? project,

    required bool isCoLeader,

    required bool showCoLeaderControls,

    required bool coLeaderLoading,

  }) {

    switch (state.loadStatus) {

      case MemberDetailLoadStatus.initial:

      case MemberDetailLoadStatus.loading:

        return CustomScrollView(

          slivers: [

            SliverPadding(

              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),

              sliver: const SliverToBoxAdapter(child: MemberDetailShimmer()),

            ),

          ],

        );

      case MemberDetailLoadStatus.error:

        return ProjectDetailLoadError(

          message: state.loadErrorMessage ?? AppStrings.errorGeneric,

          onRetry: () => context.read<MemberDetailCubit>().load(

                projectId: projectId,

                userId: member.apiUserId,

                projectName: projectName,

              ),

        );

      case MemberDetailLoadStatus.loaded:

        final loaded = activity!;

        return CustomScrollView(

          slivers: [

            SliverPadding(

              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),

              sliver: SliverToBoxAdapter(

                child: _MemberDetailBody(

                  member: displayMember,

                  activity: loaded,

                  projectId: projectId,

                  project: project,

                  isLeaderView: isLeaderView,

                  showCoLeaderControls: showCoLeaderControls,

                  isCoLeader: isCoLeader,

                  isCoLeaderActionLoading: coLeaderLoading,

                  onAssignCoLeader: showCoLeaderControls

                      ? () => _promptAssignCoLeader(context)

                      : null,

                  onRemoveCoLeader: showCoLeaderControls

                      ? () => _promptRemoveCoLeader(context)

                      : null,

                  onTakeAction: () => _openPenaltyAction(context),

                ),

              ),

            ),

          ],

        );

    }

  }

}



class _MemberDetailBody extends StatelessWidget {

  const _MemberDetailBody({

    required this.member,

    required this.activity,

    required this.projectId,

    this.project,

    required this.isLeaderView,

    required this.showCoLeaderControls,

    required this.isCoLeader,

    required this.isCoLeaderActionLoading,

    this.onAssignCoLeader,

    this.onRemoveCoLeader,

    this.onTakeAction,

  });



  final MemberEntity member;

  final MemberActivityEntity activity;

  final String projectId;

  final ProjectDetailEntity? project;

  final bool isLeaderView;

  final bool showCoLeaderControls;

  final bool isCoLeader;

  final bool isCoLeaderActionLoading;

  final VoidCallback? onAssignCoLeader;

  final VoidCallback? onRemoveCoLeader;

  final VoidCallback? onTakeAction;

  @override

  Widget build(BuildContext context) {

    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        MemberIdentitySection(

          member: member,

          username: MemberActivityDisplay.formatUsername(member),

          projectName: '',

          project: project,

          isCoLeader: isCoLeader,

          isCoLeaderActionLoading: isCoLeaderActionLoading,

          onAssignCoLeader: onAssignCoLeader,

          onRemoveCoLeader: onRemoveCoLeader,

        ),

        SizedBox(height: 16.h),

        MemberMetricsSection(

          contributed: MemberActivityDisplay.formatCurrencyMetric(

            activity.totalContributed,

          ),

          contributions: '${activity.contributionCount}',

          borrowed: MemberActivityDisplay.formatCurrencyMetric(

            activity.totalBorrowed,

          ),

        ),

        SizedBox(height: 24.h),

        MemberTransactionsSection(transactions: activity.transactions),

        if (isLeaderView && activity.hasOverdue) ...[
          SizedBox(height: 12.h),
          MemberOverdueBanner(
            member: member,
            projectId: projectId,
            project: project,
            overdueBorrowCount: activity.overdueBorrowCount,
            onTakeAction: onTakeAction,
          ),
        ],

      ],

    );

  }

}


