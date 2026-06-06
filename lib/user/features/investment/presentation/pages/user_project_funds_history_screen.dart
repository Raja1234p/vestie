import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/route_args/project_detail_flow_args.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/common/post_auth_header.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_funds_history/project_funds_history_row.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_funds_history/project_funds_history_summary.dart';

import '../models/user_investment_ui_snapshot.dart';

/// Contribution ledger for the pooled project (mock data).
class UserProjectFundsHistoryScreen extends StatelessWidget {
  final UserInvestmentUiSnapshot snapshot;

  const UserProjectFundsHistoryScreen({super.key, required this.snapshot});

  @override
  Widget build(BuildContext context) {
    final entries = snapshot.fundsHistory
        .map(
          (r) => ProjectFundsHistoryEntryArgs(
            memberName: r.memberName,
            dateLabel: r.dateLabel,
            amount: r.amount,
          ),
        )
        .toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PostAuthGradientBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PostAuthHeader(
              title: AppStrings.menuProjectFundsHistory,
              leading: AppBackButton(onPressed: () => context.pop()),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 32.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProjectFundsHistorySummary(
                      currentPotBalance: snapshot.totalProjectFundsUsd,
                      layout: ProjectFundsHistorySummaryLayout.investment,
                    ),
                    ...entries.map((e) => ProjectFundsHistoryRow(entry: e)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
