import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_tick_switch.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import '../../domain/create_project_form.dart';
import '../create_project_flow.dart';
import '../cubit/create_project_cubit.dart';
import '../widgets/create_project_header.dart';
import 'create_project_form_widgets.dart';

/// Collaborative saving flow — mirrors “Project Settings” + auto-save in product designs.
class CreateProjectSavingSettingsScreen extends StatelessWidget {
  final bool isEditMode;

  const CreateProjectSavingSettingsScreen({
    super.key,
    this.isEditMode = false,
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

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: PostAuthGradientBackground(
            child: Column(
              children: [
                CreateProjectHeader(
                  title: AppStrings.createSavingSettingsTitle,
                  stepBadge: createProjectSavingSettingsStepBadge(
                    form,
                    editMode: isEditMode,
                  ),
                  badgeColor: Colors.white,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 16.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                AppStrings.labelAutoSave,
                                style: GoogleFonts.lato(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            AppTickSwitch(
                              value: form.autoSaveEnabled,
                              onChanged: cubit.setAutoSaveEnabled,
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          AppStrings.autoSaveDescription,
                          style: GoogleFonts.lato(
                            fontSize: 13.sp,
                            height: 1.45,
                            color: Colors.black.withValues(alpha: 0.55),
                          ),
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
                      label: isEditMode
                          ? AppStrings.btnSaveChanges
                          : AppStrings.btnNext,
                      onPressed: () {
                        if (isEditMode) {
                          context.pop();
                          context.pop();
                          return;
                        }
                        context.push(AppRoutes.createProjectReview);
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
