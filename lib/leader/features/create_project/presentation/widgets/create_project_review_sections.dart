import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import '../../domain/create_project_form.dart';

String _visibilityReviewText(ProjectVisibility v) =>
    v == ProjectVisibility.public
        ? AppStrings.reviewValuePublic
        : AppStrings.reviewValuePrivate;

List<MapEntry<String, String>> buildProjectDetailsReviewRows(CreateProjectForm form) {
  final rows = <MapEntry<String, String>>[
    MapEntry(
      AppStrings.reviewLabelProjectFlow,
      form.flowType.shortLabel,
    ),
    MapEntry(
      AppStrings.reviewLabelName,
      form.projectName.isEmpty ? '—' : form.projectName,
    ),
    MapEntry(AppStrings.reviewLabelGoal, form.formattedAmount),
    MapEntry(
      AppStrings.reviewLabelDeadline,
      form.deadlineFormatted.isEmpty ? '—' : form.deadlineFormatted,
    ),
    MapEntry(AppStrings.reviewLabelCategory, form.category.label),
    MapEntry(AppStrings.reviewLabelVisibility,
        _visibilityReviewText(form.visibility)),
  ];

  final desc = form.description.trim();
  if (desc.isNotEmpty) {
    rows.add(MapEntry(AppStrings.reviewLabelDescription, desc));
  }
  return rows;
}

List<MapEntry<String, String>> buildSavingSettingsReviewRows(CreateProjectForm form) {
  return [
    MapEntry(
      AppStrings.reviewLabelAutoSave,
      form.autoSaveEnabled
          ? AppStrings.reviewValueEnabled
          : AppStrings.reviewValueDisabled,
    ),
  ];
}

List<MapEntry<String, String>> buildBorrowingSettingsReviewRows(CreateProjectForm form) {
  final rows = <MapEntry<String, String>>[
    MapEntry(
      AppStrings.reviewBorrowingEnabledLabel,
      form.borrowingEnabled
          ? AppStrings.reviewValueEnabled
          : AppStrings.reviewValueDisabled,
    ),
  ];
  if (!form.borrowingEnabled) return rows;

  final roi = form.roi.trim().isEmpty
      ? AppStrings.reviewRoiNotSet
      : '${form.roi.trim()}%';

  final months = form.repaymentWindow.trim().isEmpty
      ? AppStrings.reviewRoiNotSet
      : '${form.repaymentWindow.trim()} ${AppStrings.reviewLabelMonths}';

  rows.addAll([
    MapEntry(AppStrings.reviewAnnualInterestLabel, roi),
    MapEntry(AppStrings.reviewRepaymentMonthsLabel, months),
  ]);
  return rows;
}

/// White summary card shared by [CreateProjectReviewScreen].
class CreateProjectReviewSectionCard extends StatelessWidget {
  final String title;
  final VoidCallback onEdit;
  final List<MapEntry<String, String>> rows;

  const CreateProjectReviewSectionCard({
    super.key,
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
              Text(
                title,
                style: GoogleFonts.lato(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
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
    final isPrimaryDetailsRow = label == AppStrings.reviewLabelProjectFlow ||
        label == AppStrings.reviewLabelName ||
        label == AppStrings.reviewLabelGoal ||
        label == AppStrings.reviewLabelDeadline ||
        label == AppStrings.reviewLabelCategory ||
        label == AppStrings.reviewLabelVisibility ||
        label == AppStrings.reviewLabelDescription;

    final isLongValue = normalizedValue.length > 28;
    final valueFontSize =
        isPrimaryDetailsRow ? 30.sp : (isLongValue ? 18.sp : 24.sp);
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
