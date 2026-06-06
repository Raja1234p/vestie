import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import '../../domain/create_project_form.dart';

List<MapEntry<String, String>> buildProjectDetailsReviewRows(
  CreateProjectForm form,
) {
  return [
    MapEntry(
      AppStrings.reviewLabelName,
      form.projectName.isEmpty ? '—' : form.projectName,
    ),
    MapEntry(AppStrings.reviewLabelGoal, form.formattedAmount),
    MapEntry(
      AppStrings.reviewLabelDeadline,
      form.deadline == null ? '—' : form.deadlineIsoFormatted,
    ),
    MapEntry(AppStrings.reviewLabelCategory, form.category.label),
  ];
}

List<MapEntry<String, String>> buildInvestmentRoiReviewRows(
  CreateProjectForm form,
) {
  final raw = form.roi.trim().replaceAll('%', '');
  final roi = raw.isEmpty ? AppStrings.reviewRoiNotSet : '$raw%';
  return [MapEntry(AppStrings.labelRoiOptional, roi)];
}

/// White summary card shared by [CreateProjectReviewScreen].
class CreateProjectReviewSectionCard extends StatelessWidget {
  final String title;

  /// Only the Project Details card supplies this — edit restarts the wizard at details.
  final VoidCallback? onEdit;
  final List<MapEntry<String, String>> rows;

  const CreateProjectReviewSectionCard({
    super.key,
    required this.title,
    this.onEdit,
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
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.lato(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (onEdit != null)
                GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 15.w,
                      vertical: 7.h,
                    ),
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
          ...rows.map(
            (e) => CreateProjectReviewValueTile(label: e.key, value: e.value),
          ),
        ],
      ),
    );
  }
}

class CreateProjectReviewValueTile extends StatelessWidget {
  final String label;
  final String value;

  const CreateProjectReviewValueTile({
    super.key,
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
        label == AppStrings.reviewLabelCategory ||
        label == AppStrings.labelRoiOptional;

    final isLongValue = normalizedValue.length > 28;
    final valueFontSize = isPrimaryDetailsRow
        ? 30.sp
        : (isLongValue ? 18.sp : 24.sp);
    final valueWeight = isPrimaryDetailsRow
        ? FontWeight.w600
        : (isLongValue ? FontWeight.w500 : FontWeight.w600);
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
