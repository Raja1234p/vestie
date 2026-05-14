import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_failure_dialog.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import '../../domain/create_project_form.dart';
import '../create_project_entry_mode.dart';
import '../create_project_flow.dart';
import '../cubit/create_project_cubit.dart';
import '../cubit/create_project_submit_cubit.dart';
import '../widgets/create_project_header.dart';
import '../widgets/create_project_review_sections.dart';

/// Summary before submit — sections depend on the chosen [ProjectCreationFlowType].
class CreateProjectReviewScreen extends StatelessWidget {
  const CreateProjectReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CreateProjectSubmitCubit(),
      child: BlocBuilder<CreateProjectCubit, CreateProjectForm>(
        builder: (context, form) {
          return BlocListener<CreateProjectSubmitCubit, CreateProjectSubmitState>(
            listenWhen: (previous, current) {
              final idReady = (current.createdProject?.id ?? '').isNotEmpty &&
                  current.createdProject?.id != previous.createdProject?.id;
              final errReady = (current.error ?? '').isNotEmpty &&
                  current.error != previous.error &&
                  !current.loading;
              return idReady || errReady;
            },
            listener: (context, state) async {
              if (state.createdProject != null &&
                  state.createdProject!.id.isNotEmpty) {
                if (!context.mounted) return;
                context.push(AppRoutes.createProjectSuccess);
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
            child: Scaffold(
              backgroundColor: Colors.transparent,
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
                        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 10.h),
                        child: Column(
                          children: [
                            CreateProjectReviewSectionCard(
                              title: AppStrings.reviewSectionDetails,
                              onEdit: () => context.push(
                                AppRoutes.createProjectDetails,
                                extra: CreateProjectEntryMode.editFromReview,
                              ),
                              rows: buildProjectDetailsReviewRows(form),
                            ),
                            if (form.flowType.usesInvestmentRoiOnlySettings) ...[
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
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.viewInsetsOf(context).bottom,
                      ),
                      child: SafeArea(
                        top: false,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: BlocBuilder<CreateProjectSubmitCubit,
                              CreateProjectSubmitState>(
                            buildWhen: (p, c) => p.loading != c.loading,
                            builder: (context, submit) {
                              return AppButton(
                                text: AppStrings.btnNext,
                                useGradient: false,
                                hasShadow: false,
                                color: AppColors.neutral1200,
                                borderRadius: 10.r,
                                isLoading: submit.loading,
                                onPressed: submit.loading
                                    ? () {}
                                    : () => context
                                        .read<CreateProjectSubmitCubit>()
                                        .submit(form),
                              );
                            },
                          ),
                        ),
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
