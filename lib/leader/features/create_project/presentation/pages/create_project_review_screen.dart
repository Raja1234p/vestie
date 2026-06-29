import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/app/router/route_args/create_project_success_route_args.dart';
import 'package:vestie/features/projects/data/models/project_list_json_parsing.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_failure_dialog.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/core/widgets/common/flow_screen_footer.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import '../../domain/create_project_form.dart';
import '../create_project_entry_mode.dart';
import '../create_project_flow.dart';
import '../cubit/create_project_cubit.dart';
import '../cubit/create_project_submit_cubit.dart';
import '../cubit/create_project_update_cubit.dart';
import '../widgets/create_project_header.dart';
import '../widgets/create_project_review_sections.dart';

/// Summary before submit — sections depend on the chosen [ProjectCreationFlowType].
/// Create: `POST /projects` then `POST /projects/{id}/launch`.
/// Edit: `PUT /projects/{id}`.
class CreateProjectReviewScreen extends StatelessWidget {
  const CreateProjectReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CreateProjectSubmitCubit(),
      child: BlocBuilder<CreateProjectCubit, CreateProjectForm>(
        builder: (context, form) {
          final isEdit = form.isEditingProject;
          final detailsEntryMode = isEdit
              ? CreateProjectEntryMode.editFromProjectDetail
              : CreateProjectEntryMode.editFromReview;

          return MultiBlocListener(
            listeners: [
              BlocListener<CreateProjectSubmitCubit, CreateProjectSubmitState>(
                listenWhen: (previous, current) {
                  final idReady =
                      (current.createdProject?.id ?? '').isNotEmpty &&
                      current.createdProject?.id != previous.createdProject?.id;
                  final errReady =
                      (current.error ?? '').isNotEmpty &&
                      current.error != previous.error &&
                      !current.loading;
                  return idReady || errReady;
                },
                listener: (context, state) async {
                  if (state.createdProject != null &&
                      state.createdProject!.id.isNotEmpty) {
                    if (!context.mounted) return;
                    final created = state.createdProject!;
                    context.push(
                      AppRoutes.createProjectSuccess,
                      extra: CreateProjectSuccessRouteArgs(
                        projectId: created.id,
                        projectName: created.name,
                        isInvestment: projectTypeIsInvestment(created.type),
                      ),
                    );
                    return;
                  }
                  final err = state.error;
                  if (err != null && err.isNotEmpty && !state.loading) {
                    await AppFailureDialog.show(
                      context,
                      title: state.errorTitle,
                      message: err,
                    );
                    if (context.mounted) {
                      context.read<CreateProjectSubmitCubit>().clearError();
                    }
                  }
                },
              ),
              BlocListener<CreateProjectUpdateCubit, CreateProjectUpdateState>(
                listenWhen: (previous, current) {
                  final errReady =
                      (current.error ?? '').isNotEmpty &&
                      current.error != previous.error &&
                      !current.loading;
                  return errReady;
                },
                listener: (context, state) async {
                  final err = state.error;
                  if (err != null && err.isNotEmpty && !state.loading) {
                    await AppFailureDialog.show(
                      context,
                      title: state.errorTitle,
                      message: err,
                    );
                    if (context.mounted) {
                      context.read<CreateProjectUpdateCubit>().clearError();
                    }
                  }
                },
              ),
            ],
            child: Scaffold(
              backgroundColor: Colors.transparent,
              resizeToAvoidBottomInset: false,
              body: PostAuthGradientBackground(
                child: Column(
                  children: [
                    CreateProjectHeader(
                      title: AppStrings.createReviewTitle,
                      stepBadge: createProjectReviewStepBadge(form),
                      badgeColor: AppColors.green800,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          16.w,
                          0,
                          16.w,
                          10.h + MediaQuery.viewInsetsOf(context).bottom,
                        ),
                        child: Column(
                          children: [
                            CreateProjectReviewSectionCard(
                              title: AppStrings.reviewSectionDetails,
                              onEdit: () => context.push(
                                AppRoutes.createProjectDetails,
                                extra: detailsEntryMode,
                              ),
                              rows: buildProjectDetailsReviewRows(form),
                            ),
                            if (form
                                .flowType
                                .usesInvestmentRoiOnlySettings) ...[
                              SizedBox(height: 12.h),
                              CreateProjectReviewSectionCard(
                                title: AppStrings.reviewSectionRoi,
                                rows: buildInvestmentRoiReviewRows(form),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    FlowScreenFooter(
                      child: BlocBuilder<CreateProjectSubmitCubit,
                          CreateProjectSubmitState>(
                        buildWhen: (p, c) => p.loading != c.loading,
                        builder: (context, submit) {
                          final update =
                              context.watch<CreateProjectUpdateCubit>().state;
                          final loading =
                              isEdit ? update.loading : submit.loading;

                          return AppButton(
                            text: isEdit
                                ? AppStrings.btnEditProject
                                : AppStrings.btnCreateProject2,
                            useGradient: false,
                            hasShadow: false,
                            color: AppColors.neutral1200,
                            borderRadius: 10.r,
                            isLoading: loading,
                            onPressed: loading
                                ? null
                                : () async {
                                    if (isEdit) {
                                      final ok = await context
                                          .read<CreateProjectUpdateCubit>()
                                          .submit(form);
                                      if (!context.mounted || !ok) return;
                                      context.push(
                                        AppRoutes.createProjectSuccess,
                                        extra: CreateProjectSuccessRouteArgs(
                                          projectId: form.editingProjectId!,
                                          projectName: form.projectName,
                                          isInvestment: form.category ==
                                              NewProjectCategory.investment,
                                          isEditFlow: true,
                                        ),
                                      );
                                      return;
                                    }
                                    context
                                        .read<CreateProjectSubmitCubit>()
                                        .submit(form);
                                  },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
