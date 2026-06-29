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

import 'package:vestie/user/features/vff/domain/entities/vff_enums.dart';
import 'package:vestie/user/features/vff/presentation/widgets/user_vff_remove_connection_dialog.dart';

import '../cubit/member_detail_cubit.dart';

import '../project_detail_reload_coordinator.dart';

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

  final Future<void> Function()? onProjectMembersChanged;

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
      create: (_) =>
          MemberDetailCubit(
            getMemberActivityUseCase:
                ServiceLocator.instance.getMemberActivityUseCase,

            updateCoLeaderRoleUseCase:
                ServiceLocator.instance.updateCoLeaderRoleUseCase,

            removeMemberUseCase: ServiceLocator.instance.removeMemberUseCase,

            sendVffRequestUseCase:
                ServiceLocator.instance.sendVffRequestUseCase,

            removeVffConnectionUseCase:
                ServiceLocator.instance.removeVffConnectionUseCase,
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

  final Future<void> Function()? onProjectMembersChanged;

  /// Prefer synced detail so roster roles / moderator flags stay accurate.
  ProjectDetailEntity? get _projectContext =>
      ProjectDetailReloadCoordinator.cachedProject(projectId) ?? project;

  String _userIdForApi(MemberDetailState state, ProjectDetailEntity? project) {
    final resolved = _displayMember(state, project: project).apiUserId.trim();
    if (resolved.isNotEmpty) return resolved;
    return member.apiUserId.trim();
  }

  MemberEntity _displayMember(
    MemberDetailState state, {
    ProjectDetailEntity? project,
  }) {
    final loaded = state.activity?.member;
    final merged = loaded == null ? member : member.mergedWithActivity(loaded);
    if (project == null) return merged;
    return merged.withProjectRoster(project);
  }

  void _onStateChanged(BuildContext context, MemberDetailState state) {
    if (state.isVffRequestLoading) {
      return;
    }

    final failure = state.failure;

    if (failure != null) {
      showMemberDetailErrorDialog(context, failure: failure);

      context.read<MemberDetailCubit>().clearStatus();

      return;
    }

    final completed = state.completedAction;

    if (completed == MemberDetailAction.sendVffRequest) {
      context.read<MemberDetailCubit>().clearStatus();
    }
  }

  Future<void> _promptAssignCoLeader(BuildContext context) async {
    final p = _projectContext;
    if (p == null || !p.supportsCoLeader) return;

    final cubit = context.read<MemberDetailCubit>();
    final state = cubit.state;
    final memberName = _displayMember(state, project: p).name;
    final userId = _userIdForApi(state, p);

    await showMakeCoLeaderFlow(
      context,
      memberName: memberName,
      projectName: projectName,
      onConfirm: () => cubit.assignCoLeader(
        projectId: projectId,
        userId: userId,
      ),
    );
  }

  Future<void> _promptRemoveCoLeader(BuildContext context) async {
    final p = _projectContext;
    if (p == null || !p.supportsCoLeader) return;

    final cubit = context.read<MemberDetailCubit>();
    final state = cubit.state;
    final memberName = _displayMember(state, project: p).name;
    final userId = _userIdForApi(state, p);

    await showRemoveCoLeaderFlow(
      context,
      memberName: memberName,
      projectName: projectName,
      onConfirm: () => cubit.removeCoLeader(
        projectId: projectId,
        userId: userId,
      ),
    );
  }

  Future<void> _openPenaltyAction(BuildContext context) async {
    final p = _projectContext;
    if (p == null) return;

    final cubit = context.read<MemberDetailCubit>();
    final activity = cubit.state.activity;

    final outcome = await context.push<MemberPenaltyActionOutcome>(
      AppRoutes.memberPenaltyAction,
      extra: MemberPenaltyActionRouteArgs(
        member: _displayMember(
          cubit.state,
          project: p,
        ),
        projectId: projectId,
        project: p,
        penalty: activity?.penalty,
      ),
    );

    if (!context.mounted || outcome == null) return;

    if (outcome == MemberPenaltyActionOutcome.memberRemoved) {
      await context.read<MemberDetailCubit>().syncWithProjectDetail(
        refreshMember: false,
      );
      if (!context.mounted) return;
      context.pop(MemberDetailPopResult.memberRemoved);
      return;
    }

    await context.read<MemberDetailCubit>().syncWithProjectDetail();
    if (!context.mounted) return;
    final refreshed =
        context.read<MemberDetailCubit>().state.loadStatus ==
        MemberDetailLoadStatus.loaded;
    if (!refreshed) {
      showMemberDetailErrorDialog(
        context,
        failure: const ServerFailure(AppStrings.errorGeneric),
      );
    }
  }

  Future<void> _onRemoveVffConnection(
    BuildContext context,
    MemberEntity member,
  ) async {
    final handle = member.username.replaceFirst(RegExp(r'^@'), '').trim();
    final usernameWithoutAt = handle.isNotEmpty
        ? handle
        : member.name.replaceAll(' ', '').toLowerCase();

    await showUserVffRemoveConnectionDialog(
      context,
      usernameWithoutAt: usernameWithoutAt,
      onConfirm: () => context.read<MemberDetailCubit>().removeVffConnection(),
    );
  }

  Future<void> _promptRemoveMember(BuildContext context) async {
    final p = _projectContext;
    final cubit = context.read<MemberDetailCubit>();
    final memberName = _displayMember(cubit.state, project: p).name;
    final userId = _userIdForApi(cubit.state, p);
    final removed = await showRemoveMemberFlow(
      context,
      memberName: memberName,
      onConfirm: () => cubit.removeMember(
        projectId: projectId,
        userId: userId,
      ),
    );
    if (!context.mounted || !removed) return;
    context.pop(MemberDetailPopResult.memberRemoved);
  }

  @override
  Widget build(BuildContext context) {
    final p = _projectContext;

    return BlocListener<MemberDetailCubit, MemberDetailState>(
      listenWhen: (prev, curr) =>
          prev.isVffRequestLoading != curr.isVffRequestLoading ||
          prev.failure != curr.failure ||
          prev.completedAction != curr.completedAction,

      listener: _onStateChanged,

      child: BlocBuilder<MemberDetailCubit, MemberDetailState>(
        builder: (context, state) {
          final displayMember = _displayMember(state, project: p);

          final activity = state.activity;

          final vffConnectionState =
              MemberDetailActionsVisibility.effectiveVffConnectionState(
                member: displayMember,
                activityVffConnectionState:
                    activity?.vffConnectionState ?? VffConnectionState.none,
              );

          final vffRequestSent =
              displayMember.hasPendingVffOutgoing ||
              vffConnectionState == VffConnectionState.pendingOutgoing;

          final isCoLeader =
              displayMember.role == MemberRole.coLeader ||
              (activity?.isCoLeader ?? false);

          final showCoLeaderControls =
              p != null &&
              MemberDetailActionsVisibility.showCoLeaderControls(
                project: p,

                member: displayMember,
              );

          final showSendVff =
              p != null &&
              MemberDetailActionsVisibility.showVffSendOrSent(
                project: p,

                member: displayMember,

                vffConnectionState: vffConnectionState,
              );

          final showVffFollowing =
              p != null &&
              MemberDetailActionsVisibility.showVffFollowing(
                project: p,

                member: displayMember,

                vffConnectionState: vffConnectionState,
              );

          final showRemoveMember =
              p != null &&
              MemberDetailActionsVisibility.showRemoveMemberOnMemberProfile(
                project: p,

                member: displayMember,
              );

          final showFooter =
              p != null &&
              MemberDetailActionsVisibility.showFooter(
                project: p,

                member: displayMember,

                vffConnectionState: vffConnectionState,
              );

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
                          changed ? MemberDetailPopResult.membersUpdated : null,
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

                    ),
                  ),

                  if (showFooter &&
                      state.loadStatus != MemberDetailLoadStatus.error)
                    MemberDetailFooter(
                      showVffFollowing: showVffFollowing,

                      onRemoveVffConnection: () =>
                          _onRemoveVffConnection(context, displayMember),

                      showSendVffRequest: showSendVff,

                      vffRequestSent: vffRequestSent,

                      isVffRequestLoading: state.isVffRequestLoading,

                      showRemoveMember: showRemoveMember,

                      onSendVffRequest: () =>
                          context.read<MemberDetailCubit>().sendVffRequest(),

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
  }) {
    switch (state.loadStatus) {
      case MemberDetailLoadStatus.initial:
      case MemberDetailLoadStatus.loading:
        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),

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
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),

              sliver: SliverToBoxAdapter(
                child: _MemberDetailBody(
                  member: displayMember,

                  activity: loaded,

                  projectId: projectId,

                  project: project,

                  isLeaderView: isLeaderView,

                  showCoLeaderControls: showCoLeaderControls,

                  isCoLeader: isCoLeader,

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

    this.isCoLeaderActionLoading = false,

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
