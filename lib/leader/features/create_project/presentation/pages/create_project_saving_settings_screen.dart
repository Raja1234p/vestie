import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/core/widgets/common/app_tick_switch.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import '../../domain/create_project_form.dart';
import '../create_project_entry_mode.dart';
import '../create_project_flow.dart';
import '../cubit/create_project_cubit.dart';
import '../widgets/create_project_header.dart';

/// Collaborative saving flow — mirrors “Project Settings” + auto-save in product designs.
class CreateProjectSavingSettingsScreen extends StatelessWidget {
  final CreateProjectEntryMode entryMode;

  const CreateProjectSavingSettingsScreen({
    super.key,
    this.entryMode = CreateProjectEntryMode.wizard,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateProjectCubit, CreateProjectForm>(
      builder: (context, form) {
        final cubit = context.read<CreateProjectCubit>();
        if (!form.flowType.usesSavingSettings) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            context.pop();
          });
          return const Scaffold(body: SizedBox.shrink());
        }

        final settingsLabelStyle = Theme.of(context).textTheme.bodyLarge
            ?.copyWith(
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.authLabel,
            );
        final helperStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontSize: 13.sp,
          height: 1.45,
          color: AppColors.authHint,
        );

        return Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: false,
          body: PostAuthGradientBackground(
            child: Column(
              children: [
                CreateProjectHeader(
                  title: AppStrings.createSavingSettingsTitle,
                  stepBadge: createProjectSavingSettingsStepBadge(
                    form,
                    editMode: entryMode.isEditFlow,
                  ),
                  badgeColor: Colors.white,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      20.w,
                      10.h,
                      20.w,
                      16.h + MediaQuery.viewInsetsOf(context).bottom,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                AppStrings.labelAutoSave,
                                style: settingsLabelStyle,
                              ),
                            ),
                            AppTickSwitch(
                              value: form.autoSaveEnabled,
                              onChanged: cubit.setAutoSaveEnabled,
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          AppStrings.autoSaveDescription,
                          style: helperStyle,
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
                      onPressed: () =>
                          context.push(AppRoutes.createProjectReview),
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
