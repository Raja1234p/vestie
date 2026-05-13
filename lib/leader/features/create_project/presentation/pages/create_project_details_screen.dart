import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/core/widgets/common/app_svg_icon.dart';
import 'package:vestie/core/widgets/common/app_text_field.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import '../../domain/create_project_form.dart';
import '../create_project_entry_mode.dart';
import '../create_project_flow.dart';
import '../cubit/create_project_cubit.dart';
import '../widgets/create_project_header.dart';
import 'create_project_details_fields.dart';
import 'create_project_form_widgets.dart';

/// Project metadata — category selects the wizard (investment ROI vs vacation/emergency borrow).
class CreateProjectDetailsScreen extends StatefulWidget {
  final CreateProjectEntryMode entryMode;

  const CreateProjectDetailsScreen({
    super.key,
    this.entryMode = CreateProjectEntryMode.wizard,
  });

  @override
  State<CreateProjectDetailsScreen> createState() =>
      _CreateProjectDetailsScreenState();
}

class _CreateProjectDetailsScreenState extends State<CreateProjectDetailsScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;

  @override
  void initState() {
    super.initState();
    final form = context.read<CreateProjectCubit>().state;
    _nameCtrl = TextEditingController(text: form.projectName);
    _descCtrl = TextEditingController(text: form.description);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext ctx) async {
    final cubit = ctx.read<CreateProjectCubit>();
    // Calendar "today" at midnight — past days are not selectable.
    final today = DateUtils.dateOnly(DateTime.now());
    // Picker requires a finite lastDate — allow choosing deadlines up to 20 years ahead.
    final lastDay = DateTime(today.year + 20, today.month, today.day);

    final stored = cubit.state.deadline;
    final storedDay =
        stored != null ? DateUtils.dateOnly(stored) : null;

    DateTime initial;
    if (storedDay != null) {
      initial = storedDay.isBefore(today) ? today : storedDay;
    } else {
      // Open on the current month; +30d was scrolling the grid to next month.
      initial = today;
    }
    if (initial.isAfter(lastDay)) initial = lastDay;

    final picked = await showDatePicker(
      context: ctx,
      initialDate: initial,
      firstDate: today,
      lastDate: lastDay,
      // Input mode can accept dates outside [firstDate, lastDate]; calendar-only + predicate fixes that.
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      selectableDayPredicate: (DateTime day) {
        final d = DateUtils.dateOnly(day);
        return !d.isBefore(today);
      },
      builder: (c, child) => Theme(
        data: Theme.of(c).copyWith(
          colorScheme: ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      final chosen = DateUtils.dateOnly(picked);
      if (!chosen.isBefore(today)) {
        cubit.setDeadline(chosen);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateProjectCubit, CreateProjectForm>(
      builder: (context, form) {
        final cubit = context.read<CreateProjectCubit>();
        final detailsLabelStyle =
            Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.authLabel,
                );
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: PostAuthGradientBackground(
            child: Column(
              children: [
                CreateProjectHeader(
                  title: AppStrings.createDetailsTitle,
                  stepBadge: createProjectDetailsStepBadge(
                    form,
                    editMode: widget.entryMode.isEditFlow,
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 16.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppTextField(
                          label: AppStrings.labelProjectName,
                          hint: AppStrings.hintProjectName,
                          controller: _nameCtrl,
                          textInputAction: TextInputAction.next,
                          errorText: form.nameError,
                          onChanged: cubit.setProjectName,
                          labelStyle: detailsLabelStyle,
                          fillColor: AppColors.searchBarBg,
                        ),
                        SizedBox(height: 16.h),
                        AppTextField(
                          label: AppStrings.labelProjectDesc,
                          hint: AppStrings.hintProjectDesc,
                          controller: _descCtrl,
                          minLines: 4,
                          maxLines: 4,
                          textInputAction: TextInputAction.done,
                          errorText: form.descError,
                          onChanged: cubit.setDescription,
                          labelStyle: detailsLabelStyle,
                          fillColor: AppColors.searchBarBg,
                          labelTrailingGap: 6.w,
                          labelTrailing: AppSvgIcon(
                            assetPath: AppAssets.iconInformationCircle,
                            size: 16,
                            color: AppColors.inputFieldIcon,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        CPFieldLabel(AppStrings.labelCategory),
                        CPCategoryDropdown(
                          value: form.category,
                          onChanged: cubit.setCategory,
                        ),
                        SizedBox(height: 16.h),
                        CPFieldLabel(AppStrings.labelDeadline),
                        CPDeadlinePicker(
                          label: form.deadlineFormatted.isEmpty
                              ? AppStrings.deadlinePlaceholder
                              : form.deadlineFormatted,
                          isEmpty: form.deadline == null,
                          errorText: form.deadlineError,
                          onTap: () => _pickDate(context),
                        ),
                        SizedBox(height: 16.h),
                        CPFieldLabel(AppStrings.labelVisibility),
                        CPVisibilityToggle(
                          value: form.visibility,
                          onChanged: cubit.setVisibility,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.viewInsetsOf(context).bottom,
                  ),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: AppButton(
                        text: AppStrings.btnNext,
                        useGradient: false,
                        hasShadow: false,
                        color: AppColors.neutral1200,
                        borderRadius: 10.r,
                        onPressed: () => pushNextAfterDetailsStep(
                              context,
                              cubit,
                              entryMode: widget.entryMode,
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
}
