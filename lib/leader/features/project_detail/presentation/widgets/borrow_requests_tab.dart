import 'package:flutter/material.dart';

import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_detail_view_all_link.dart';
import 'package:vestie/features/project_detail/domain/entities/borrow_request_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/borrow_request_entity_extensions.dart';
import 'package:vestie/features/project_detail/domain/entities/member_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/presentation/widgets/borrow_requests_empty_state.dart';
import 'borrow_request_card.dart';

/// Inline borrow requests tab — preview cards, View All → full list, header tap → member profile.
class BorrowRequestsTab extends StatelessWidget {
  final ProjectDetailEntity project;
  final List<BorrowRequestEntity> requests;
  final VoidCallback onViewAll;
  final BorrowRequestActionMode actionMode;
  final ValueChanged<MemberEntity>? onMemberTap;
  final void Function(BorrowRequestEntity request)? onAccept;
  final void Function(BorrowRequestEntity request)? onReject;
  final Future<void> Function()? onVoteSuccess;

  const BorrowRequestsTab({
    super.key,
    required this.project,
    required this.requests,
    required this.onViewAll,
    this.actionMode = BorrowRequestActionMode.vote,
    this.onMemberTap,
    this.onAccept,
    this.onReject,
    this.onVoteSuccess,
  });

  VoidCallback? _openMemberDetail(BorrowRequestEntity request) {
    final onTap = onMemberTap;
    if (onTap == null || !project.canReviewMemberProfiles) return null;

    final member = request.resolveMember(project.members);
    if (member == null) return null;

    return () => onTap(member);
  }

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return const BorrowRequestsEmptyState(
        compactTop: true,
        title: AppStrings.projectDetailBorrowRequestsEmpty,
      );
    }

    final preview = requests.take(2).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProjectDetailViewAllLink(
          label: AppStrings.viewAllRequests,
          onTap: onViewAll,
        ),
        ...preview.map(
          (r) => BorrowRequestCard(
            key: ValueKey(
              '${r.id}|${r.callerVote}|${r.upvotes}|${r.downvotes}',
            ),
            projectId: project.id,
            request: r,
            actionMode: actionMode,
            hideVoteActions:
                actionMode == BorrowRequestActionMode.vote &&
                r.isRequestedByViewer(project),
            onOpenMemberDetail: _openMemberDetail(r),
            onAccept: onAccept != null ? () => onAccept!(r) : null,
            onReject: onReject != null ? () => onReject!(r) : null,
            onVoteSuccess: onVoteSuccess,
          ),
        ),
        SizedBox(height: AppDimens.v15),
      ],
    );
  }
}
