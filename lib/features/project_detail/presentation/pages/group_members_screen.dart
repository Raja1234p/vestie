import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/core/utils/app_snackbar.dart';
import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/common/post_auth_header.dart';
import 'package:vestie/features/project_detail/domain/entities/member_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/member_entity_extensions.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/app/router/route_args/project_detail_flow_args.dart';
import 'package:vestie/features/project_detail/presentation/navigation/project_detail_navigation_helpers.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_member_row.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_members_empty_state.dart';
import 'package:vestie/features/project_detail/presentation/project_detail_reload_coordinator.dart';
import 'package:vestie/features/projects/presentation/bloc/project_detail_bloc.dart';
import 'package:vestie/user/features/vff/domain/entities/vff_enums.dart';

/// Full-screen group members list (View All Members).
class GroupMembersScreen extends StatefulWidget {
  final List<MemberEntity> members;
  final String projectId;
  final ProjectDetailEntity? project;

  const GroupMembersScreen({
    super.key,
    required this.members,
    required this.projectId,
    this.project,
  });

  @override
  State<GroupMembersScreen> createState() => _GroupMembersScreenState();
}

class _GroupMembersScreenState extends State<GroupMembersScreen> {
  late List<MemberEntity> _members;
  String? _sendingVffUserId;

  @override
  void initState() {
    super.initState();
    _members = widget.members;
  }

  List<MemberEntity> get _activeMembers => _members
      .where((m) => !m.status.toLowerCase().contains('pending'))
      .toList(growable: false);

  Future<void> _sendVff({
    required ProjectDetailEntity project,
    required MemberEntity member,
  }) async {
    final userId = member.apiUserId;
    if (userId.isEmpty || _sendingVffUserId != null) return;
    if (member.hasPendingVffOutgoing || member.isVffConnected) return;

    setState(() => _sendingVffUserId = userId);

    final result = await ServiceLocator.instance.sendVffRequestUseCase(
      projectId: project.id,
      userId: userId,
    );

    if (!mounted) return;

    await result.fold(
      (failure) async {
        setState(() => _sendingVffUserId = null);
        AppSnackBar.showError(context, FailureMapper.userMessage(failure));
      },
      (sent) async {
        setState(() {
          _members = _members
              .map(
                (m) => m.matchesIdentity(member)
                    ? m.copyWith(
                        vffConnectionState: VffConnectionState.pendingOutgoing,
                        canSendVffRequest: false,
                        pendingVffRequestId:
                            sent.id.isNotEmpty ? sent.id : m.pendingVffRequestId,
                      )
                    : m,
              )
              .toList(growable: false);
        });
        try {
          await context
              .read<ProjectDetailBloc>()
              .reloadDetailAndWait(project.id);
        } on ProviderNotFoundException {
          await ProjectDetailReloadCoordinator.reload(project.id);
        }
        if (!mounted) return;
        setState(() => _sendingVffUserId = null);
      },
    );
  }

  Future<void> _openMemberProfile(
    BuildContext context, {
    required ProjectDetailEntity project,
    required MemberEntity member,
  }) async {
    final result = await ProjectDetailNavigationHelpers.openMemberProfile(
      context,
      project: project,
      member: member,
    );
    if (!context.mounted || result == null) return;

    if (result == MemberDetailPopResult.memberRemoved) {
      if (!context.mounted) return;
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = _activeMembers;
    final p = widget.project;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PostAuthGradientBackground(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: PostAuthHeader(
                title: AppStrings.groupMembersTitle,
                leading: AppBackButton(onPressed: () => context.pop()),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 32.h),
              sliver: active.isEmpty
                  ? const SliverFillRemaining(
                      hasScrollBody: false,
                      child: ProjectMembersEmptyState(centered: true),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) {
                          final member = active[i];
                          return Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: ProjectMemberRow(
                              member: member,
                              project: p,
                              onTap: p != null && p.canReviewMemberProfiles
                                  ? (_) => _openMemberProfile(
                                        context,
                                        project: p,
                                        member: member,
                                      )
                                  : null,
                              onAddFriend: p != null &&
                                      p.canReviewMemberProfiles
                                  ? () => _sendVff(
                                        project: p,
                                        member: member,
                                      )
                                  : null,
                              isSendVffLoading:
                                  _sendingVffUserId == member.apiUserId,
                              vffRequestSent: member.hasPendingVffOutgoing,
                            ),
                          );
                        },
                        childCount: active.length,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
