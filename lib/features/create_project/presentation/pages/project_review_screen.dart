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
                stepBadge: '3/3',
                badgeColor: AppColors.green800,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 10.h),
                  child: Column(
                    children: [
                      _ReviewSection(
                        title: AppStrings.reviewSectionDetails,
                        onEdit: () => context.push(AppRoutes.createProjectDetails, extra: true),
                        rows: [
                          _row(AppStrings.reviewLabelName, form.projectName.isEmpty ? '—' : form.projectName),
                          _row(AppStrings.reviewLabelGoal, form.formattedAmount),
                          _row(AppStrings.reviewLabelDeadline, form.deadlineFormatted.isEmpty ? '—' : form.deadlineFormatted),
                          _row(AppStrings.reviewLabelCategory, form.category.label),
                          // _row(AppStrings.reviewLabelDescription, form.description.isEmpty ? '—' : form.description),
                          // _row(AppStrings.reviewLabelVisibility,
                          //     form.visibility == ProjectVisibility.public
                          //         ? AppStrings.reviewValuePublic
                          //         : AppStrings.reviewValuePrivate),
                          // _row(AppStrings.reviewLabelType,
                          //     form.borrowingEnabled ? AppStrings.reviewValueEnabled : AppStrings.reviewValueDisabled),
                          // if (form.borrowingEnabled) ...[
                          //   _row(AppStrings.reviewLabelLimit, '\$${form.borrowLimit.isEmpty ? '0' : form.borrowLimit}.00'),
                          //   _row(AppStrings.reviewLabelWindow, '${form.repaymentWindow.isEmpty ? '0' : form.repaymentWindow} ${AppStrings.reviewValueDays}'),
                          //   _row(AppStrings.reviewLabelPenalty, '${form.penalty.isEmpty ? '0' : form.penalty}%'),
                          // ],
                          // _row('', form.roi.isEmpty
                          //     ? AppStrings.reviewRoiNotSet
                          //     : '${form.roi}%'),
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
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.cardBorder.withValues(alpha: 0.9),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: GoogleFonts.lato(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 15.w, vertical: 7.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                  child: Text(
                    AppStrings.btnEdit,
                    style: GoogleFonts.lato(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ...rows.map((e) => _ReviewValueTile(label: e.key, value: e.value)),
        ],
      ),
    );
  }
}

class _ReviewValueTile extends StatelessWidget {
  final String label;
  final String value;

  const _ReviewValueTile({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedValue = value.trim().isEmpty ? '—' : value.trim();
    final isPrimaryDetailsRow =
        label == AppStrings.reviewLabelName ||
        label == AppStrings.reviewLabelGoal ||
        label == AppStrings.reviewLabelDeadline ||
        label == AppStrings.reviewLabelCategory;

    final isLongValue = normalizedValue.length > 28;
    final valueFontSize = isPrimaryDetailsRow ? 30.sp : (isLongValue ? 18.sp : 24.sp);
    final valueWeight = isPrimaryDetailsRow ? FontWeight.w600 : (isLongValue ? FontWeight.w500 : FontWeight.w600);
    final labelFontSize = isPrimaryDetailsRow ? 18.sp : 14.sp;
    final labelColor = isPrimaryDetailsRow
        ? AppColors.grey700
        : AppColors.primary.withValues(alpha: 0.7);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: AppColors.searchBarBg.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty)
            Text(
              '$label:',
              style: GoogleFonts.lato(
                fontSize: labelFontSize,
                fontWeight: FontWeight.w500,
                color: labelColor,
              ),
            ),
          SizedBox(height: label.isNotEmpty ? 8.h : 0),
          Text(
            normalizedValue,
            style: GoogleFonts.lato(
              fontSize: valueFontSize,
              fontWeight: valueWeight,
              color: AppColors.grey900,
              height: isLongValue ? 1.3 : 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
