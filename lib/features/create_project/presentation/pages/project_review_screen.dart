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
import '../widgets/project_review_widgets.dart';
import 'form_helpers.dart';

/// Step 3/3 — Review all sections before creating the project.
class ProjectReviewScreen extends StatelessWidget {
  const ProjectReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateProjectCubit, CreateProjectForm>(
      builder: (context, form) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: PostAuthGradientBackground(
            child: Column(
              children: [
              CreateProjectHeader(
                title: AppStrings.createReviewTitle,
                stepBadge: '3/3',
                badgeColor: AppColors.green800,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 10.h),
                  child: Column(
                    children: [
                      ProjectReviewSection(
                        title: AppStrings.reviewSectionDetails,
                        onEdit: () => context.push(AppRoutes.createProjectDetails, extra: true),
                        rows: buildProjectDetailsRows(form),
                      ),
                    ],
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 14.h),
                  child: CPNextButton(
                    label: AppStrings.btnCreateProject2,
                    onPressed: () =>
                        context.push(AppRoutes.createProjectSuccess),
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
