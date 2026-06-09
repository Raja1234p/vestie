import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/widgets/common/app_toast.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/common/post_auth_header.dart';
import 'package:vestie/features/project_detail/domain/entities/borrow_request_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/borrow_request_entity_extensions.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/presentation/navigation/project_detail_navigation.dart';
import 'package:vestie/features/project_detail/presentation/widgets/borrow_requests_empty_state.dart';
import 'package:vestie/user/features/borrow/presentation/navigation/borrow_project_detail_sync.dart';

import '../widgets/borrow_request_card.dart';
import '../widgets/borrow_request_decision_dialogs.dart';

/// Full-screen borrow requests list.
class BorrowRequestsScreen extends StatefulWidget {
  final List<BorrowRequestEntity> requests;
  final bool isLeaderMode;
  final String projectId;
  final String? screenTitle;
  final ProjectDetailEntity? project;

  const BorrowRequestsScreen({
    super.key,
    required this.requests,
    required this.projectId,
    this.isLeaderMode = false,
    this.screenTitle,
    this.project,
  });

  @override
  State<BorrowRequestsScreen> createState() => _BorrowRequestsScreenState();
}

class _BorrowRequestsScreenState extends State<BorrowRequestsScreen> {
  late List<BorrowRequestEntity> _requests;

  @override
  void initState() {
    super.initState();
    _requests = List<BorrowRequestEntity>.from(widget.requests);
  }

  Future<void> _reloadRequests() async {
    final result = await ServiceLocator.instance.listBorrowRequestsUseCase(
      projectId: widget.projectId,
      status: 'Pending',
    );
    if (!mounted) return;
    result.fold(
      (_) {
        // Load failure — keep current list; no toast (AppErrorView pattern).
      },
      (items) => setState(() => _requests = items),
    );
  }

  VoidCallback? _openMemberDetail(
    BuildContext context,
    BorrowRequestEntity request,
  ) {
    final p = widget.project;
    if (p == null || !p.canReviewMemberProfiles) return null;

    final member = request.resolveMember(p.members);
    if (member == null) return null;

    return () {
      ProjectDetailNavigation.openMemberProfile(
        context,
        project: p,
        member: member,
      );
    };
  }

  Future<bool> _approve(
    BuildContext context,
    BorrowRequestEntity request,
  ) async {
    final result = await ServiceLocator.instance.approveBorrowRequestUseCase(
      projectId: widget.projectId,
      borrowRequestId: request.id,
    );
    return result.fold((failure) {
      AppToast.showError(context, failure.message);
      return false;
    }, (_) async {
      await BorrowProjectDetailSync.reloadBeforeSuccess(widget.projectId);
      if (!context.mounted) return false;
      await _reloadRequests();
      return true;
    });
  }

  Future<bool> _reject(
    BuildContext context,
    BorrowRequestEntity request,
  ) async {
    final result = await ServiceLocator.instance.rejectBorrowRequestUseCase(
      projectId: widget.projectId,
      borrowRequestId: request.id,
    );
    return result.fold((failure) {
      AppToast.showError(context, failure.message);
      return false;
    }, (_) async {
      await BorrowProjectDetailSync.reloadBeforeSuccess(widget.projectId);
      if (!context.mounted) return false;
      await _reloadRequests();
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PostAuthGradientBackground(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: PostAuthHeader(
                title: widget.screenTitle ?? AppStrings.borrowRequestsTitle,
                leading: AppBackButton(onPressed: () => context.pop()),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 32.h),
              sliver: _requests.isEmpty
                  ? const SliverFillRemaining(
                      hasScrollBody: false,
                      child: BorrowRequestsEmptyState(centered: true),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) {
                          final request = _requests[i];
                          final project = widget.project;
                          return BorrowRequestCard(
                          projectId: widget.projectId,
                          request: request,
                          actionMode: widget.isLeaderMode
                              ? BorrowRequestActionMode.decision
                              : BorrowRequestActionMode.vote,
                          hideVoteActions: !widget.isLeaderMode &&
                              project != null &&
                              request.isRequestedByViewer(project),
                          onOpenMemberDetail: _openMemberDetail(
                            context,
                            request,
                          ),
                          onAccept: widget.isLeaderMode
                              ? () => showApproveBorrowRequestFlow(
                                  context,
                                  request,
                                  () => _approve(context, request),
                                )
                              : null,
                          onReject: widget.isLeaderMode
                              ? () => showRejectBorrowRequestFlow(
                                  context,
                                  request,
                                  () => _reject(context, request),
                                )
                              : null,
                          onVoteSuccess: widget.isLeaderMode
                              ? null
                              : _reloadRequests,
                        );
                        },
                        childCount: _requests.length,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
