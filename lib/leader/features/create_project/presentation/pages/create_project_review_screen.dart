import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import '../../domain/create_project_form.dart';
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
            listener: (context, state) {
              if (state.createdProjectId != null &&
                  state.createdProjectId!.isNotEmpty) {
                context.push(AppRoutes.createProjectSuccess);
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
                                extra: true,
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
                            BlocBuilder<CreateProjectSubmitCubit,
                                CreateProjectSubmitState>(
                              buildWhen: (p, c) => p.error != c.error,
                              builder: (context, submit) {
                                if (submit.error == null ||
                                    submit.error!.isEmpty) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: EdgeInsets.only(top: 12.h),
                                  child: Text(
                                    submit.error!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: AppColors.error),
                                  ),
                                );
                              },
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
                          child: BlocBuilder<CreateProjectSubmitCubit,
                              CreateProjectSubmitState>(
                            buildWhen: (p, c) => p.loading != c.loading,
                            builder: (context, submit) {
                              return AppButton(
                                text: AppStrings.btnNext,
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
