import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/features/project_detail/domain/entities/borrow_request_entity.dart';
import 'package:vestie/features/project_detail/presentation/widgets/borrow_requests_empty_state.dart';
import 'borrow_request_card.dart';

/// Inline borrow requests tab: preview cards, empty state, or "View All".
class BorrowRequestsTab extends StatelessWidget {
  final List<BorrowRequestEntity> requests;
  final VoidCallback onViewAll;
  final BorrowRequestActionMode actionMode;
  final void Function(BorrowRequestEntity request)? onAccept;
  final void Function(BorrowRequestEntity request)? onReject;

  const BorrowRequestsTab({
    super.key,
    required this.requests,
    required this.onViewAll,
    this.actionMode = BorrowRequestActionMode.vote,
    this.onAccept,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ViewAllRequestsLink(onTap: onViewAll),
          const BorrowRequestsEmptyState(compactTop: true),
        ],
      );
    }

    final preview = requests.take(2).toList();
    return Column(
      children: [
        ...preview.map(
          (r) => BorrowRequestCard(
            request: r,
            actionMode: actionMode,
            onAccept: onAccept != null ? () => onAccept!(r) : null,
            onReject: onReject != null ? () => onReject!(r) : null,
          ),
        ),
        if (requests.length > 2) ...[
          SizedBox(height: 10.h),
          _ViewAllRequestsLink(onTap: onViewAll),
        ],
      ],
    );
  }
}

class _ViewAllRequestsLink extends StatelessWidget {
  final VoidCallback onTap;

  const _ViewAllRequestsLink({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: AppText(
            AppStrings.viewAllRequests,
            style: GoogleFonts.lato(
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.neutral1200,
            ),
          ),
        ),
      ),
    );
  }
}
