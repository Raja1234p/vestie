import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/app/router/route_args/project_detail_flow_args.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/text/app_text.dart';

import 'my_borrow_history_row.dart';

/// Past borrow requests when there is no pending or repayable active row.
class MyBorrowHistoryBody extends StatelessWidget {
  final List<MyBorrowHistoryEntry> history;

  const MyBorrowHistoryBody({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
