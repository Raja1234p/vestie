import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/create_project_form.dart';

/// Tappable deadline field with optional inline error message.
class CPDeadlinePicker extends StatelessWidget {
  final String label;
  final bool isEmpty;
  final String? errorText;
  final VoidCallback onTap;

  const CPDeadlinePicker({
    super.key,
    required this.label,
    required this.isEmpty,
    required this.onTap,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 48.h,
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            decoration: BoxDecoration(
              color: AppColors.searchBarBg,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: hasError ? AppColors.error : AppColors.cardBorder,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.lato(
                      fontSize: 14.sp,
                      color: isEmpty ? AppColors.authHint : AppColors.textPrimary,
                    ),
                  ),
                ),
                Icon(Icons.calendar_month_outlined,
                    size: 20.w, color: AppColors.textBody),
              ],
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: EdgeInsets.only(top: 4.h, left: 4.w),
            child: Text(
              errorText!,
              style: GoogleFonts.lato(fontSize: 11.sp, color: AppColors.error),
            ),
          ),
      ],
    );
  }
}

/// Category selector dropdown for the project details form.
class CPCategoryDropdown extends StatelessWidget {
  final NewProjectCategory value;
  final ValueChanged<NewProjectCategory> onChanged;
  const CPCategoryDropdown({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: AppColors.searchBarBg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<NewProjectCategory>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              size: 22.w, color: AppColors.textBody),
          style: GoogleFonts.lato(fontSize: 14.sp, color: AppColors.textPrimary),
          items: NewProjectCategory.values.map((c) {
            return DropdownMenuItem(value: c, child: Text(c.label));
          }).toList(),
          onChanged: (v) { if (v != null) onChanged(v); },
        ),
      ),
    );
  }
}

/// Public / Private toggle for the project details form.
class CPVisibilityToggle extends StatelessWidget {
  final ProjectVisibility value;
  final ValueChanged<ProjectVisibility> onChanged;
  const CPVisibilityToggle({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44.h,
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: AppColors.grey200,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: ProjectVisibility.values.map((v) {
          final isActive = v == value;
          final label = v == ProjectVisibility.public
              ? AppStrings.visibilityPublic
              : AppStrings.visibilityPrivate;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(v),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeInOut,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  label,
                  style: GoogleFonts.lato(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
