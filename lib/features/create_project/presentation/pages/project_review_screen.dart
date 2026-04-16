import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/post_auth_gradient_background.dart';
import '../../domain/create_project_form.dart';
import '../cubit/create_project_cubit.dart';
import '../widgets/create_project_header.dart';
import 'form_helpers.dart';

/// Step 3/3 — Review all sections before creating the project.
class ProjectReviewScreen extends StatelessWidget {
  const ProjectReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateProjectCubit, CreateProjectForm>(
      builder: (context, form) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: PostAuthGradientBackground(
            child: Column(
              children: [
              CreateProjectHeader(
                title: AppStrings.createReviewTitle,
                stepBadge: '4/4',
                badgeColor: AppColors.green800,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 10.h),
                  child: Column(
                    children: [
                      // Project Details
                      _ReviewSection(
                        title: AppStrings.reviewSectionDetails,
                        onEdit: () => context.push(AppRoutes.createProjectDetails, extra: true),
                        rows: [
                          _row(AppStrings.reviewLabelName, form.projectName.isEmpty ? '—' : form.projectName),
                          _row(AppStrings.reviewLabelGoal, form.formattedAmount),
                          _row(AppStrings.reviewLabelDeadline, form.deadlineFormatted.isEmpty ? '—' : form.deadlineFormatted),
                          _row(AppStrings.reviewLabelCategory, form.category.label),
                        ],
                      ),
                      SizedBox(height: 10.h),

                      // Description & Rules
                      _ReviewSection(
                        title: AppStrings.reviewSectionDescRules,
                        onEdit: () => context.push(AppRoutes.createProjectDetails, extra: true),
                        rows: [
                          _row(AppStrings.reviewLabelDescription, form.description.isEmpty ? '—' : form.description),
                          _row(AppStrings.reviewLabelVisibility,
                              form.visibility == ProjectVisibility.public
                                  ? AppStrings.reviewValuePublic
                                  : AppStrings.reviewValuePrivate),
                        ],
                      ),
                      SizedBox(height: 10.h),

                      // Borrowing
                      _ReviewSection(
                        title: AppStrings.reviewSectionBorrowing,
                        onEdit: () => context.push(AppRoutes.createProjectBorrowing, extra: true),
                        rows: [
                          _row(AppStrings.reviewLabelType,
                              form.borrowingEnabled ? AppStrings.reviewValueEnabled : AppStrings.reviewValueDisabled),
                          if (form.borrowingEnabled) ...[
                            _row(AppStrings.reviewLabelLimit, '\$${form.borrowLimit.isEmpty ? '0' : form.borrowLimit}.00'),
                            _row(AppStrings.reviewLabelWindow, '${form.repaymentWindow.isEmpty ? '0' : form.repaymentWindow} ${AppStrings.reviewValueDays}'),
                            _row(AppStrings.reviewLabelPenalty, '${form.penalty.isEmpty ? '0' : form.penalty}%'),
                          ],
                        ],
                      ),
                      SizedBox(height: 10.h),

                      // ROI
                      _ReviewSection(
                        title: AppStrings.reviewSectionRoi,
                        onEdit: () => context.push(AppRoutes.createProjectBorrowing, extra: true),
                        rows: [
                          _row('', form.roi.isEmpty
                              ? AppStrings.reviewRoiNotSet
                              : '${form.roi}%'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 14.h),
                  child: CPNextButton(
                    label: AppStrings.btnCreateProject2,
                    onPressed: () =>
                        context.push(AppRoutes.createProjectSuccess),
                  ),
                ),
              ),
              ],
            ),
          ),
        );
      },
    );
  }

  MapEntry<String, String> _row(String k, String v) => MapEntry(k, v);
}

class _ReviewSection extends StatelessWidget {
  final String title;
  final VoidCallback onEdit;
  final List<MapEntry<String, String>> rows;

  const _ReviewSection({
    required this.title,
    required this.onEdit,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: GoogleFonts.lato(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary)),
              GestureDetector(
                onTap: onEdit,
                child: Text(AppStrings.btnEdit,
                    style: GoogleFonts.lato(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary)),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          // Content rows
          ...rows.map((e) => Padding(
                padding: EdgeInsets.only(top: 2.h),
                child: Text(
                  e.key.isEmpty ? e.value : '${e.key}: ${e.value}',
                  style: GoogleFonts.lato(
                      fontSize: 12.sp,
                      color: AppColors.textBody,
                      height: 1.5),
                ),
              )),
        ],
      ),
    );
  }
}
