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
import '../create_project_flow.dart';
import '../cubit/create_project_cubit.dart';
import '../widgets/create_project_header.dart';
import 'create_project_details_fields.dart';
import 'create_project_form_widgets.dart';

/// Project metadata — category selects the wizard (investment ROI vs vacation/emergency borrow).
class CreateProjectDetailsScreen extends StatefulWidget {
  final bool isEditMode;

  const CreateProjectDetailsScreen({super.key, this.isEditMode = false});

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
    final picked = await showDatePicker(
      context: ctx,
      initialDate: cubit.state.deadline ??
          DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (c, child) => Theme(
        data: Theme.of(c).copyWith(
          colorScheme: ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) cubit.setDeadline(picked);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateProjectCubit, CreateProjectForm>(
      builder: (context, form) {
        final cubit = context.read<CreateProjectCubit>();
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: PostAuthGradientBackground(
            child: Column(
              children: [
                CreateProjectHeader(
                  title: AppStrings.createDetailsTitle,
                  stepBadge: createProjectDetailsStepBadge(
                    form,
                    editMode: widget.isEditMode,
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
                        ),
                        SizedBox(height: 16.h),
                        AppTextField(
                          label: AppStrings.labelProjectDesc,
                          hint: AppStrings.hintProjectDesc,
                          controller: _descCtrl,
                          maxLines: 4,
                          textInputAction: TextInputAction.done,
                          errorText: form.descError,
                          onChanged: cubit.setDescription,
                          labelTrailing: AppSvgIcon(
                            assetPath: AppAssets.iconInfo,
                            size: 18.w,
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
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 20.w,
                      right: 20.w,
                      bottom: 20.h + MediaQuery.viewInsetsOf(context).bottom,
                    ),
                    child: AppButton(
                      text: AppStrings.btnNext,
                      useGradient: false,
                      hasShadow: false,
                      color: AppColors.neutral1200,
                      borderRadius: 16.r,
                      onPressed: () => pushNextAfterDetailsStep(
                            context,
                            cubit,
                            editMode: widget.isEditMode,
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
