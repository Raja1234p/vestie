import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/utils/app_snackbar.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/common/post_auth_header.dart';
import 'package:vestie/features/project_detail/domain/entities/borrow_request_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/borrow_request_entity_extensions.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/presentation/navigation/project_detail_navigation_helpers.dart';
import 'package:vestie/features/project_detail/presentation/widgets/borrow_requests_empty_state.dart';

import '../widgets/borrow_request_card.dart';
import '../widgets/borrow_request_decision_dialogs.dart';

/// Full-screen borrow requests list.
/// Receives a [List] of [BorrowRequestEntity] via GoRouter extra.
class BorrowRequestsScreen extends StatelessWidget {
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

  VoidCallback? _openMemberDetail(
    BuildContext context,
    BorrowRequestEntity request,
  ) {
    final p = project;
    if (p == null || !p.canReviewMemberProfiles) return null;

    final member = request.resolveMember(p.members);
    if (member == null) return null;

    return () {
      ProjectDetailNavigationHelpers.openMemberProfile(
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
      projectId: projectId,
      borrowRequestId: request.id,
    );
    return result.fold((failure) {
      AppSnackBar.showError(context, failure.message);
      return false;
    }, (_) => true);
  }

  Future<bool> _reject(
    BuildContext context,
    BorrowRequestEntity request,
  ) async {
    final result = await ServiceLocator.instance.rejectBorrowRequestUseCase(
      projectId: projectId,
      borrowRequestId: request.id,
    );
    return result.fold((failure) {
      AppSnackBar.showError(context, failure.message);
      return false;
    }, (_) => true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PostAuthGradientBackground(
        child: CustomScrollView(
          slivers: [
            // ── Header ──────────────────────────────────────
            SliverToBoxAdapter(
              child: PostAuthHeader(
                title: screenTitle ?? AppStrings.borrowRequestsTitle,
                leading: AppBackButton(onPressed: () => context.pop()),
              ),
            ),

            // ── List ────────────────────────────────────────
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 32.h),
              sliver: requests.isEmpty
                  ? const SliverFillRemaining(
                      hasScrollBody: false,
                      child: BorrowRequestsEmptyState(centered: true),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => BorrowRequestCard(
                          request: requests[i],
                          actionMode: isLeaderMode
                              ? BorrowRequestActionMode.decision
                              : BorrowRequestActionMode.vote,
                          onOpenMemberDetail: _openMemberDetail(
                            context,
                            requests[i],
                          ),
                          onAccept: isLeaderMode
                              ? () => showApproveBorrowRequestFlow(
                                  context,
                                  requests[i],
                                  () => _approve(context, requests[i]),
                                )
                              : null,
                          onReject: isLeaderMode
                              ? () => showRejectBorrowRequestFlow(
                                  context,
                                  requests[i],
                                  () => _reject(context, requests[i]),
                                )
                              : null,
                        ),
                        childCount: requests.length,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
