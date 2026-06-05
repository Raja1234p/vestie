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

// ── Keyboard / release layout (same pattern on details, saving, ROI, borrow, review) ──
// Scaffold: resizeToAvoidBottomInset: false so the footer Next button is not shifted twice.
// Do NOT add MediaQuery.viewInsets.bottom padding on the footer row when using that flag.
// Form area: SingleChildScrollView bottom padding += viewInsets.bottom so fields can scroll above the IME.

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
    final today = CreateProjectCubit.calendarDate(DateTime.now());
    final lastDay = DateTime(today.year + 20, today.month, today.day);

    final stored = cubit.state.deadline;
    final storedDay =
        stored != null ? CreateProjectCubit.calendarDate(stored) : null;

    DateTime initial;
    if (storedDay != null) {
      initial = storedDay.isBefore(today) ? today : storedDay;
    } else {
      initial = today;
    }
    if (initial.isAfter(lastDay)) initial = lastDay;

    final result = await showProjectDeadlinePicker(
      ctx,
      initial: initial,
      firstDate: today,
      lastDate: lastDay,
      allowClear: stored != null,
    );

    if (!ctx.mounted) return;

    switch (result.action) {
      case ProjectDeadlinePickerAction.cancelled:
        return;
      case ProjectDeadlinePickerAction.cleared:
        cubit.clearDeadline();
        return;
      case ProjectDeadlinePickerAction.confirmed:
        final chosen = CreateProjectCubit.calendarDate(result.date!);
        if (chosen.isBefore(today) || chosen.isAfter(lastDay)) return;
        cubit.setDeadline(chosen);
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
          resizeToAvoidBottomInset: false,
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
                    padding: EdgeInsets.fromLTRB(
                      20.w,
                      20.h,
                      20.w,
                      16.h + MediaQuery.viewInsetsOf(context).bottom,
                    ),
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
                            assetPath: AppAssets.iconInfoCircle,
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
                          onClear: form.deadline != null
                              ? cubit.clearDeadline
                              : null,
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
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
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
              ],
            ),
          ),
        );
      },
    );
  }
}
