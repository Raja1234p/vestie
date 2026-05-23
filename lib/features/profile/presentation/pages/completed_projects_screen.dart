import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/core/widgets/common/app_shimmer.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/features/project_detail/presentation/navigation/open_project_from_card.dart'
    show openCompletedProjectView;
import 'package:vestie/user/features/home/presentation/widgets/project_card.dart';
import 'package:vestie/user/features/vff/presentation/widgets/user_vff_hub_empty_body.dart';
import '../cubit/completed_projects_cubit.dart';
import '../widgets/profile_sub_header.dart';

class CompletedProjectsScreen extends StatelessWidget {
  const CompletedProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CompletedProjectsCubit(),
      child: const _CompletedProjectsBody(),
    );
  }
}

class _CompletedProjectsBody extends StatelessWidget {
  const _CompletedProjectsBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CompletedProjectsCubit, CompletedProjectsState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: PostAuthGradientBackground(
            child: Column(
              children: [
                ProfileSubHeader(title: AppStrings.completedProjectsTitle),
                Expanded(child: _buildBody(context, state)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, CompletedProjectsState state) {
    if (state.loading) {
      return ListView.builder(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
        itemCount: 3,
        itemBuilder: (_, __) => const ProjectCardShimmer(),
      );
    }
    if (state.errorMessage != null) {
      return _ErrorView(
        message: state.errorMessage!,
        onRetry: () => context.read<CompletedProjectsCubit>().load(),
      );
    }
    if (state.projects.isEmpty) {
      return _EmptyView();
    }
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
      itemCount: state.projects.length,
      itemBuilder: (_, i) {
        final project = state.projects[i];
        return ProjectCard(
          project: project,
          forceShowActionButton: true,
          onAction: () => openCompletedProjectView(context, project),
        );
      },
    );
  }
}

class _EmptyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const UserVffHubEmptyBody(
      message: AppStrings.completedProjectsEmptyTitle,
      subtitle: AppStrings.completedProjectsEmptySubtitle,
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppText(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textBody,
                height: 1.45,
              ),
            ),
            SizedBox(height: 20.h),
            AppButton(
              text: AppStrings.btnRetry,
              width: 280.w,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
