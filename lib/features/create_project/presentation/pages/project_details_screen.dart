import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/post_auth_gradient_background.dart';
import '../../domain/create_project_form.dart';
import '../cubit/create_project_cubit.dart';
import '../widgets/create_project_header.dart';
import 'form_helpers.dart';
import 'project_details_widgets.dart';

/// Step 1/3 – Project name, description, category, deadline, visibility.
///
/// Uses [StatefulWidget] solely to manage [TextEditingController] lifecycle.
/// All reactive state (form data, validation errors) lives in [CreateProjectCubit].
/// Zero [setState] calls.
class ProjectDetailsScreen extends StatefulWidget {
  /// True when navigated from the Review screen's "Edit" button.
  /// In this mode the header shows no badge and "Next" pops back to Review.
  final bool isEditMode;
  const ProjectDetailsScreen({super.key, this.isEditMode = false});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
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
                stepBadge: widget.isEditMode ? null : '2/4',
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CPFieldLabel(AppStrings.labelProjectName),
                      CPTextField(
                        controller: _nameCtrl,
                        hint: AppStrings.hintProjectName,
                        textInputAction: TextInputAction.next,
                        errorText: form.nameError,
                        onChanged: cubit.setProjectName,
                      ),
                      SizedBox(height: 16.h),

                      CPFieldLabel(AppStrings.labelProjectDesc),
                      CPTextField(
                        controller: _descCtrl,
                        hint: AppStrings.hintProjectDesc,
                        maxLines: 4,
                        textInputAction: TextInputAction.done,
                        errorText: form.descError,
                        onChanged: cubit.setDescription,
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
                  padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 14.h),
                  child: CPNextButton(
                    label: widget.isEditMode
                        ? AppStrings.btnSaveChanges
                        : AppStrings.btnNext,
                    onPressed: () {
                      if (!cubit.validateDetails()) return;
                      widget.isEditMode
                          ? context.pop()
                          : context.push(AppRoutes.createProjectBorrowing);
                    },
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
