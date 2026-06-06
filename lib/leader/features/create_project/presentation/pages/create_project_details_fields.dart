import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_svg_icon.dart';
import '../../domain/create_project_form.dart';
import '../cubit/create_project_cubit.dart';

final _categoryDropdownRadius = BorderRadius.circular(AppRadius.r12);

enum ProjectDeadlinePickerAction { cancelled, cleared, confirmed }

class ProjectDeadlinePickerResult {
  const ProjectDeadlinePickerResult._(this.action, [this.date]);

  final ProjectDeadlinePickerAction action;
  final DateTime? date;

  static const cancelled = ProjectDeadlinePickerResult._(
    ProjectDeadlinePickerAction.cancelled,
  );
  static const cleared = ProjectDeadlinePickerResult._(
    ProjectDeadlinePickerAction.cleared,
  );
  static ProjectDeadlinePickerResult confirmed(DateTime date) =>
      ProjectDeadlinePickerResult._(
        ProjectDeadlinePickerAction.confirmed,
        date,
      );
}

/// OK saves the picked day; Cancel dismisses without changing form/API; Remove deadline clears it.
Future<ProjectDeadlinePickerResult> showProjectDeadlinePicker(
  BuildContext context, {
  required DateTime initial,
  required DateTime firstDate,
  required DateTime lastDate,
  bool allowClear = false,
}) {
  return showDialog<ProjectDeadlinePickerResult>(
    context: context,
    builder: (dialogContext) => _ProjectDeadlinePickerDialog(
      initial: CreateProjectCubit.calendarDate(initial),
      firstDate: CreateProjectCubit.calendarDate(firstDate),
      lastDate: CreateProjectCubit.calendarDate(lastDate),
      allowClear: allowClear,
    ),
  ).then((value) => value ?? ProjectDeadlinePickerResult.cancelled);
}

class _ProjectDeadlinePickerDialog extends StatefulWidget {
  final DateTime initial;
  final DateTime firstDate;
  final DateTime lastDate;
  final bool allowClear;

  const _ProjectDeadlinePickerDialog({
    required this.initial,
    required this.firstDate,
    required this.lastDate,
    this.allowClear = false,
  });

  @override
  State<_ProjectDeadlinePickerDialog> createState() =>
      _ProjectDeadlinePickerDialogState();
}

class _ProjectDeadlinePickerDialogState
    extends State<_ProjectDeadlinePickerDialog> {
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      contentPadding: EdgeInsets.zero,
      actionsPadding: EdgeInsets.only(right: 4.w, bottom: 2.h),
      content: SizedBox(
        width: double.maxFinite,
        height: 430.h,
        child: CalendarDatePicker(
          initialDate: _selected,
          firstDate: widget.firstDate,
          lastDate: widget.lastDate,
          onDateChanged: (date) {
            setState(() {
              _selected = CreateProjectCubit.calendarDate(date);
            });
          },
          selectableDayPredicate: (day) {
            final d = CreateProjectCubit.calendarDate(day);
            return !d.isBefore(widget.firstDate) && !d.isAfter(widget.lastDate);
          },
        ),
      ),
      actions: [
        if (widget.allowClear)
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(ProjectDeadlinePickerResult.cleared),
            child: Text(AppStrings.btnRemoveDeadline),
          ),
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(ProjectDeadlinePickerResult.cancelled),
          child: Text(AppStrings.btnCancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(
            context,
          ).pop(ProjectDeadlinePickerResult.confirmed(_selected)),
          child: Text(AppStrings.btnOk),
        ),
      ],
    );
  }
}

/// Tappable deadline field with optional inline error message.
class CPDeadlinePicker extends StatelessWidget {
  final String label;
  final bool isEmpty;
  final String? errorText;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const CPDeadlinePicker({
    super.key,
    required this.label,
    required this.isEmpty,
    required this.onTap,
    this.errorText,
    this.onClear,
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
                      color: isEmpty
                          ? AppColors.authHint
                          : AppColors.inputFieldText,
                    ),
                  ),
                ),
                if (!isEmpty && onClear != null) ...[
                  Tooltip(
                    message: AppStrings.btnRemoveDeadline,
                    child: GestureDetector(
                      onTap: onClear,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: Semantics(
                          label: AppStrings.btnRemoveDeadline,
                          button: true,
                          child: Icon(
                            Icons.close,
                            size: 20.w,
                            color: AppColors.inputFieldIcon,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                AppSvgIcon(
                  assetPath: AppAssets.createProjectCalendar,
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

/// Category selector — inline expandable panel (Figma Project Details).
class CPCategoryDropdown extends StatefulWidget {
  final NewProjectCategory value;
  final ValueChanged<NewProjectCategory> onChanged;

  const CPCategoryDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<CPCategoryDropdown> createState() => _CPCategoryDropdownState();
}

class _CPCategoryDropdownState extends State<CPCategoryDropdown> {
  bool _expanded = false;

  BoxDecoration _boxDecoration(Color fill) => BoxDecoration(
    color: fill,
    borderRadius: _categoryDropdownRadius,
    border: Border.all(color: AppColors.inputFieldBorder),
  );

  TextStyle get _optionTextStyle => GoogleFonts.lato(
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.inputFieldText,
  );

  void _toggleExpanded() => setState(() => _expanded = !_expanded);

  void _select(NewProjectCategory category) {
    widget.onChanged(category);
    setState(() => _expanded = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: _toggleExpanded,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimens.p16,
              vertical: 14.h,
            ),
            decoration: _boxDecoration(AppColors.searchBarBg),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.value.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _optionTextStyle,
                  ),
                ),
                Transform.rotate(
                  angle: _expanded ? math.pi : 0,
                  child: AppSvgIcon(
                    assetPath: AppAssets.iconChevronDown,
                    size: 22.w,
                    color: AppColors.inputFieldIcon,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_expanded) ...[
          SizedBox(height: AppDimens.v8),
          Container(
            decoration: _boxDecoration(AppColors.searchBarBg),
            padding: EdgeInsets.symmetric(vertical: AppDimens.v8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final category in NewProjectCategory.values)
                  _CategoryOptionTile(
                    label: category.label,
                    style: _optionTextStyle,
                    onTap: () => _select(category),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _CategoryOptionTile extends StatelessWidget {
  final String label;
  final TextStyle style;
  final VoidCallback onTap;

  const _CategoryOptionTile({
    required this.label,
    required this.style,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: _categoryDropdownRadius,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimens.p16,
            vertical: 14.h,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(label, style: style),
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
  const CPVisibilityToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

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
