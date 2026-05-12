import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_svg_icon.dart';
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
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: AppColors.searchBarBg,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: hasError ? AppColors.error : AppColors.inputFieldBorder,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.lato(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: isEmpty ? AppColors.authHint : AppColors.inputFieldText,
                    ),
                  ),
                ),
                AppSvgIcon(
                  assetPath: AppAssets.iconCalendar,
                  size: 20.w,
                  color: AppColors.inputFieldIcon,
                ),
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

/// Category selector — opens a bottom sheet so users can dismiss with Cancel
/// or by tapping outside (avoids Dropdown overlay that can feel impossible to close).
class CPCategoryDropdown extends StatelessWidget {
  final NewProjectCategory value;
  final ValueChanged<NewProjectCategory> onChanged;
  const CPCategoryDropdown({super.key, required this.value, required this.onChanged});

  Future<void> _openPicker(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      barrierColor: AppColors.modalBarrier,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            16.w,
            0,
            16.w,
            16.h + MediaQuery.viewPaddingOf(sheetContext).bottom,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadius.r12),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 10.h),
                Container(
                  width: 36.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.grey400,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppStrings.labelCategory,
                      style: GoogleFonts.lato(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.inputFieldText,
                      ),
                    ),
                  ),
                ),
                for (final c in NewProjectCategory.values)
                  ListTile(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
                    title: Text(
                      c.label,
                      style: GoogleFonts.lato(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.inputFieldText,
                      ),
                    ),
                    trailing: c == value
                        ? Icon(
                            Icons.check,
                            color: AppColors.inputFieldIcon,
                            size: 22.w,
                          )
                        : null,
                    onTap: () {
                      onChanged(c);
                      Navigator.of(sheetContext).pop();
                    },
                  ),
                Padding(
                  padding: EdgeInsets.fromLTRB(12.w, 4.h, 12.w, 8.h),
                  child: SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      child: Text(
                        AppStrings.btnCancel,
                        style: GoogleFonts.lato(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.inputFieldIcon,
                        ),
                      ),
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

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openPicker(context),
        borderRadius: BorderRadius.circular(12.r),
        child: Ink(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: AppColors.searchBarBg,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.inputFieldBorder),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.lato(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.inputFieldText,
                    ),
                  ),
                ),
              ),
              AppSvgIcon(
                assetPath: AppAssets.iconChevronDown,
                size: 22.w,
                color: AppColors.inputFieldIcon,
              ),
            ],
          ),
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
      height: 50.h,
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
