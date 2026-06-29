import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/presentation/paginated_scroll_listener.dart';
import 'package:vestie/core/presentation/widgets/list_load_more_footer.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/core/widgets/common/app_toast.dart';
import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/common/post_auth_header.dart';
import 'package:vestie/features/project_detail/domain/entities/member_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/member_entity_extensions.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/app/router/route_args/project_detail_flow_args.dart';
import 'package:vestie/features/project_detail/presentation/navigation/project_detail_navigation.dart';
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
  ProjectDetailEntity? _project;
  String? _sendingVffUserId;
  bool _loadingMore = false;
  int _membersPage = 1;
  int _membersTotalCount = 0;
  final ScrollController _scrollController = ScrollController();
  PaginatedScrollListener? _scrollListener;

  bool get _hasMore => _members.length < _membersTotalCount;

  @override
  void initState() {
    super.initState();
    _members = widget.members;
    _project = widget.project;
    _membersTotalCount = widget.project?.membersPagination.totalCount ??
        widget.members.length;
    _scrollListener = PaginatedScrollListener(
      controller: _scrollController,
      onLoadMore: _loadMoreMembers,
    );
  }

  @override
  void dispose() {
    _scrollListener?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMoreMembers() async {
    if (_loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);
    final nextPage = _membersPage + 1;
    final result =
        await ServiceLocator.instance.projectDetailRepository.getProjectDetail(
      projectId: widget.projectId,
      membersPage: nextPage,
    );
    if (!mounted) return;
    result.fold(
      (_) => setState(() => _loadingMore = false),
      (project) => setState(() {
        final existingIds = _members.map((m) => m.membershipId).toSet();
        final newMembers = project.members
            .where((m) => !existingIds.contains(m.membershipId))
            .toList(growable: false);
        _members = [..._members, ...newMembers];
        _project = project;
        _membersPage = project.membersPagination.page;
        _membersTotalCount = project.membersPagination.totalCount;
        _loadingMore = false;
      }),
    );
  }

  List<MemberEntity> get _activeMembers => _members
      .where((m) => !m.status.toLowerCase().contains('pending'))
      .toList(growable: false);

  /// Prefer bloc-synced detail so viewerRole / moderator flags stay accurate.
  ProjectDetailEntity? get _projectContext =>
      ProjectDetailReloadCoordinator.cachedProject(widget.projectId) ??
      _project ??
      widget.project;

  Future<void> _sendVff({
    required ProjectDetailEntity project,
    required MemberEntity member,
  }) async {
    final userId = member.apiUserId;
    if (userId.isEmpty || _sendingVffUserId != null) return;
    if (member.hasPendingVffOutgoing || member.isViewerVffLinked) return;

    setState(() => _sendingVffUserId = userId);

    final result = await ServiceLocator.instance.sendVffRequestUseCase(
      projectId: project.id,
      userId: userId,
    );

    if (!mounted) return;

    await result.fold(
      (failure) async {
        setState(() => _sendingVffUserId = null);
        AppToast.showError(context, FailureMapper.userMessage(failure));
      },
      (sent) async {
        setState(() {
          _members = _members
              .map(
                (m) => m.matchesIdentity(member)
                    ? m.copyWith(
                        vffConnectionState: VffConnectionState.pendingOutgoing,
                        canSendVffRequest: false,
                        pendingVffRequestId: sent.id.isNotEmpty
                            ? sent.id
                            : m.pendingVffRequestId,
                      )
                    : m,
              )
              .toList(growable: false);
        });
        try {
          await context.read<ProjectDetailBloc>().reloadDetailAndWait(
            project.id,
          );
        } on ProviderNotFoundException {
          await ProjectDetailReloadCoordinator.reload(project.id);
        }
        if (!mounted) return;
        setState(() => _sendingVffUserId = null);
      },
    );
  }

  /// Applies members/co-leader badges from the project detail reload member
  /// detail already performed — no extra API in the normal stack path.
  Future<void> _applySyncedMembers() async {
    final cached = ProjectDetailReloadCoordinator.cachedProject(widget.projectId);
    if (cached != null) {
      setState(() {
        _members = cached.members;
        _project = cached;
      });
      return;
    }

    final result =
        await ServiceLocator.instance.projectDetailRepository.getProjectDetail(
      projectId: widget.projectId,
    );
    if (!mounted) return;
    result.fold((_) {}, (project) {
      setState(() {
        _members = project.members;
        _project = project;
      });
    });
  }

  Future<void> _openMemberProfile(
    BuildContext context, {
    required ProjectDetailEntity project,
    required MemberEntity member,
  }) async {
    final result = await ProjectDetailNavigation.openMemberProfile(
      context,
      project: project,
      member: member,
    );
    if (!context.mounted || result == null) return;

    if (result == MemberDetailPopResult.memberRemoved) {
      if (!context.mounted) return;
      context.pop();
      return;
    }

    if (result == MemberDetailPopResult.membersUpdated) {
      await _applySyncedMembers();
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = _activeMembers;
    final p = _projectContext;

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: PostAuthGradientBackground(
        child: Column(
          children: [
            PostAuthHeader(
              title: AppStrings.groupMembersTitle,
              leading: AppBackButton(onPressed: () => context.pop()),
            ),
            Expanded(child: _buildBody(context, active: active, project: p)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context, {
    required List<MemberEntity> active,
    required ProjectDetailEntity? project,
  }) {
    if (active.isEmpty) {
      return const ProjectMembersEmptyState(centered: true);
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 32.h),
      itemCount: active.length + 1,
      itemBuilder: (_, i) {
        if (i == active.length) {
          return ListLoadMoreFooter(loadingMore: _loadingMore);
        }
        final member = active[i];
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: ProjectMemberRow(
            member: member,
            project: project,
            onTap: project != null && project.canReviewMemberProfiles
                ? (_) => _openMemberProfile(
                    context,
                    project: project,
                    member: member,
                  )
                : null,
            onAddFriend: project != null && project.canReviewMemberProfiles
                ? () => _sendVff(project: project, member: member)
                : null,
            isSendVffLoading: _sendingVffUserId == member.apiUserId,
            vffRequestSent: member.hasPendingVffOutgoing,
          ),
        );
      },
    );
  }
}
