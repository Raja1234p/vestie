import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/member_project_flow/member_project_form_widgets.dart';
import 'package:vestie/core/widgets/member_project_flow/member_project_header.dart';

import '../models/create_project_fund_draft.dart';
import '../models/create_project_status_screen_args.dart';

/// Contribution progress ring + mocked history (`create_project_contribution_progress_screen`).
class CreateProjectContributionProgressScreen extends StatelessWidget {
  final CreateProjectFundDraft draft;

  const CreateProjectContributionProgressScreen({
    super.key,
    required this.draft,
  });

  @override
  Widget build(BuildContext context) {
    final pct = draft.mockPercentTowardGoal;
    final raised = NumberFormat('#,##0.00', 'en_US').format(draft.mockRaisedUsd);
    final goal = NumberFormat('#,##0.00', 'en_US').format(draft.goalAmountUsd);

    final history = [
      _MockTx('Alex', '12 May 2024', 120.0),
      _MockTx('Jordan', '3 May 2024', 85.0),
      _MockTx('Riley', '28 Apr 2024', 200.0),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PostAuthGradientBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MemberFundFlowHeader(title: AppStrings.contributionProgressTitle),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
                child: Column(
                  children: [
                    SizedBox(height: 8.h),
                    SizedBox(
                      height: 160.h,
                      width: 160.h,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox.expand(
                            child: CircularProgressIndicator(
                              value: pct / 100,
                              strokeWidth: 10,
                              backgroundColor:
                                  AppColors.purple300.withValues(alpha: 0.25),
                              color: AppColors.primary,
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$pct%',
                                style: GoogleFonts.lato(
                                  fontSize: 32.sp,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                AppStrings.contributionProgressSubtitle,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.lato(
                                  fontSize: 11.sp,
                                  color: AppColors.textBody,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      '\$$raised / \$$goal USD',
                      style: GoogleFonts.lato(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 28.h),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        AppStrings.contributionHistoryTitle,
                        style: GoogleFonts.lato(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color:
                              AppColors.cardBorder.withValues(alpha: 0.55),
                        ),
                      ),
                      child: Column(
                        children: List.generate(history.length, (i) {
                          final h = history[i];
                          final isLast = i == history.length - 1;
                          return Column(
                            children: [
                              ListTile(
                                contentPadding:
                                    EdgeInsets.symmetric(
                                  horizontal: 14.w,
                                  vertical: 4.h,
                                ),
                                leading: SvgPicture.asset(
                                  AppAssets.transactionDeposit,
                                  width: 32.w,
                                  height: 32.w,
                                ),
                                title: Text(
                                  h.name,
                                  style: GoogleFonts.lato(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                subtitle: Text(
                                  h.date,
                                  style: GoogleFonts.lato(
                                    fontSize: 11.sp,
                                    color: AppColors.textBody,
                                  ),
                                ),
                                trailing: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '\$${NumberFormat('#,##0.00').format(h.amount)}',
                                      style: GoogleFonts.lato(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13.sp,
                                      ),
                                    ),
                                    SvgPicture.asset(
                                      AppAssets.voteArrowUp,
                                      width: 18.w,
                                      height: 18.w,
                                    ),
                                  ],
                                ),
                              ),
                              if (!isLast)
                                const Divider(
                                  height: 1,
                                  color: AppColors.cardBorder,
                                ),
                            ],
                          );
                        }),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      AppStrings.contributionProgressDemoHint,
                      style: GoogleFonts.lato(
                        fontSize: 12.sp,
                        height: 1.35,
                        color: AppColors.authHint,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextButton(
                      onPressed: () => context.push(
                        AppRoutes.createProjectFundStatus,
                        extra: CreateProjectStatusScreenArgs(
                          success: true,
                          draft: draft,
                        ),
                      ),
                      child: Text(
                        AppStrings.btnSimulatePaymentSuccess,
                        style: GoogleFonts.lato(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push(
                        AppRoutes.createProjectFundStatus,
                        extra: CreateProjectStatusScreenArgs(
                          success: false,
                          draft: draft,
                        ),
                      ),
                      child: Text(
                        AppStrings.btnSimulatePaymentFailure,
                        style: GoogleFonts.lato(
                          fontWeight: FontWeight.w800,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 14.h),
                child: MemberFundPrimaryButton(
                  label: AppStrings.btnDone,
                  onPressed: () => context.pop(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MockTx {
  final String name;
  final String date;
  final double amount;

  const _MockTx(this.name, this.date, this.amount);
}
