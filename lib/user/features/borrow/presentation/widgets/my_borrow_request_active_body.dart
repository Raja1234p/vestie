import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/app/router/route_args/project_detail_flow_args.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/utils/formatters.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/features/project_detail/domain/entities/borrow_request_entity.dart';

import 'my_borrow_history_row.dart';
import 'my_borrow_member_votes.dart';

/// Active My Borrow Request — amount, votes, history (Figma).
class MyBorrowRequestActiveBody extends StatelessWidget {
  final BorrowRequestEntity activeRequest;
  final List<MyBorrowHistoryEntry> history;

  const MyBorrowRequestActiveBody({
    super.key,
    required this.activeRequest,
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          AppText(
            AppStrings.myBorrowAmountLabel,
            style: GoogleFonts.lato(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.projectDetailText,
            ),
          ),
          SizedBox(height: 10.h),
          AppText(
            AppFormatters.formatCurrency(activeRequest.requestedAmount),
            style: GoogleFonts.lato(
              fontSize: 30.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.projectDetailText,
              height: 1.1,
            ),
          ),
          SizedBox(height: 20.h),
          MyBorrowMemberVotes(
            upvotes: activeRequest.upvotes,
            downvotes: activeRequest.downvotes,
          ),
          SizedBox(height: 20.h),
          AppText(
            AppStrings.myBorrowHistoryLabel,
            style: GoogleFonts.lato(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.projectDetailText,
            ),
          ),
          SizedBox(height: 10.h),
          ...history.map((e) => MyBorrowHistoryRow(entry: e)),
        ],
    );
  }
}
