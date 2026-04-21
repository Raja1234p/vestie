import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/text/app_text.dart';
import '../../domain/entities/borrow_request_entity.dart';
import '../../domain/entities/member_entity.dart';
import 'borrow_requests_tab.dart';
import 'borrow_request_card.dart';
import 'borrow_request_decision_dialogs.dart';
import 'leader_manage_members_list.dart';
import 'members_list.dart';

class UserBorrowRequestsPanel extends StatelessWidget {
  final List<BorrowRequestEntity> requests;
  final VoidCallback onViewAll;

  const UserBorrowRequestsPanel({
    super.key,
    required this.requests,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return BorrowRequestsTab(
      requests: requests,
      onViewAll: onViewAll,
    );
  }
}

class LeaderBorrowRequestsPanel extends StatelessWidget {
  final List<BorrowRequestEntity> requests;
  final VoidCallback onViewAll;

  const LeaderBorrowRequestsPanel({
    super.key,
    required this.requests,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final preview = requests.take(2).toList();
    return Column(
      children: [
        ...preview.map(
          (r) => BorrowRequestCard(
            request: r,
            actionMode: BorrowRequestActionMode.decision,
            onAccept: () => showApproveBorrowRequestFlow(context, r),
            onReject: () => showRejectBorrowRequestFlow(context, r),
          ),
        ),
        if (requests.length > 2) ...[
          SizedBox(height: 10.h),
          GestureDetector(
            onTap: onViewAll,
            behavior: HitTestBehavior.opaque,
            child: Center(
              child: Container(
                width: double.infinity,
                color: AppColors.grey100,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                alignment: Alignment.center,
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
          ),
        ],
      ],
    );
  }
}

class UserMembersPanel extends StatelessWidget {
  final List<MemberEntity> members;
  final ValueChanged<MemberEntity>? onMemberTap;

  const UserMembersPanel({
    super.key,
    required this.members,
    this.onMemberTap,
  });

  @override
  Widget build(BuildContext context) {
    return MembersList(
      members: members,
      onMemberTap: onMemberTap,
    );
  }
}

class LeaderMembersPanel extends StatelessWidget {
  final List<MemberEntity> members;
  final ValueChanged<MemberEntity>? onMemberTap;

  const LeaderMembersPanel({
    super.key,
    required this.members,
    this.onMemberTap,
  });

  @override
  Widget build(BuildContext context) {
    return LeaderManageMembersList(
      members: members,
      onMemberTap: onMemberTap,
    );
  }
}
