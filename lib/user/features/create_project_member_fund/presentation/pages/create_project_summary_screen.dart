import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/member_project_flow/member_project_form_widgets.dart';
import 'package:vestie/core/widgets/member_project_flow/member_project_header.dart';

import '../models/create_project_fund_draft.dart';

/// Project summary (`create_project_summary_screen` — precedes mock detail view).
class CreateProjectSummaryScreen extends StatelessWidget {
  final CreateProjectFundDraft draft;

  const CreateProjectSummaryScreen({super.key, required this.draft});

  @override
  Widget build(BuildContext context) {
    final subtitle = draft.kind == CreateProjectFundKind.vacation
        ? AppStrings.createSummarySubtitleVacation
        : AppStrings.createSummarySubtitleEmergency;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PostAuthGradientBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MemberFundFlowHeader(title: AppStrings.createProjectSummaryTitle),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      draft.projectName,
                      style: GoogleFonts.lato(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      subtitle,
                      style: GoogleFonts.lato(
                        fontSize: 13.sp,
                        height: 1.45,
                        color: AppColors.textBody,
                      ),
                    ),
                    SizedBox(height: 18.h),
                    _StoryCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _summaryRow(
                            AppStrings.summaryLabelGoal,
                            draft.formattedGoalUsd,
                          ),
                          _divider(),
                          _summaryRow(
                            AppStrings.summaryLabelStarts,
                            draft.formatDate(draft.startDate),
                          ),
                          _divider(),
                          _summaryRow(
                            AppStrings.summaryLabelEnds,
                            draft.formatDate(draft.endDate),
                          ),
                          _divider(),
                          _summaryRow(
                            AppStrings.summaryLabelAbout,
                            draft.description.isEmpty
                                ? AppStrings.summaryPlaceholderDescription
                                : draft.description,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 14.h),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.h),
                      child: Text(
                        AppStrings.summaryDesignNotePlaceholder,
                        style: GoogleFonts.lato(
                          fontSize: 12.sp,
                          height: 1.35,
                          color: AppColors.authHint,
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
                  label: AppStrings.btnCreateProject2,
                  onPressed: () => context.push(
                    AppRoutes.createProjectFundDetail,
                    extra: draft,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String k, String v) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 96.w,
          child: Text(
            k,
            style: GoogleFonts.lato(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textBody,
            ),
          ),
        ),
        Expanded(
          child: Text(
            v,
            style: GoogleFonts.lato(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              height: 1.35,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _divider() => Padding(
    padding: EdgeInsets.symmetric(vertical: 12.h),
    child: const Divider(height: 1, color: AppColors.cardBorder),
  );
}

class _StoryCard extends StatelessWidget {
  final Widget child;

  const _StoryCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 10),
            color: Colors.black.withValues(alpha: 0.06),
          ),
        ],
      ),
      child: child,
    );
  }
}
