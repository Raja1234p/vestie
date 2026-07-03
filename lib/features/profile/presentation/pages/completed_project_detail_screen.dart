import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/common/app_toast.dart';
import 'package:vestie/core/widgets/common/member_project_action_menu.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/common/post_auth_header.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/features/project_detail/presentation/navigation/project_detail_navigation.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_detail_load_error.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_detail_loading_body.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_member_vff_send_actions.dart';
import 'package:vestie/features/projects/presentation/bloc/project_detail_bloc.dart';
import '../widgets/profile_completed_project_detail_content.dart';

/// Read-only completed project detail from Profile → Completed Projects.
///
/// Loads `GET /projects/{id}` only — no pot, borrow, or voting side calls.
class CompletedProjectDetailScreen extends StatelessWidget {
  const CompletedProjectDetailScreen({
    super.key,
    required this.projectId,
    this.initialProjectName,
  });

  final String projectId;
  final String? initialProjectName;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ServiceLocator.instance.createCompletedProjectDetailBloc()
            ..add(LoadProjectDetailEvent(projectId: projectId)),
      child: _CompletedProjectDetailBody(
        projectId: projectId,
        initialProjectName: initialProjectName,
      ),
    );
  }
}

class _CompletedProjectDetailBody extends StatelessWidget {
  const _CompletedProjectDetailBody({
    required this.projectId,
    required this.initialProjectName,
  });

  final String projectId;
  final String? initialProjectName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PostAuthGradientBackground(
        child: BlocConsumer<ProjectDetailBloc, ProjectDetailState>(
          listenWhen: (prev, curr) =>
              curr is ProjectDetailLoaded &&
              curr.vffSendErrorMessage != null &&
              curr.vffSendErrorMessage !=
                  (prev is ProjectDetailLoaded
                      ? prev.vffSendErrorMessage
                      : null),
          listener: (context, state) {
            if (state is! ProjectDetailLoaded) return;
            final message = state.vffSendErrorMessage;
            if (message == null || message.isEmpty) return;
            AppToast.showError(context, message);
            context.read<ProjectDetailBloc>().add(
              const ClearMemberVffSendErrorEvent(),
            );
          },
          builder: (context, state) {
            if (state is ProjectDetailError) {
              return ProjectDetailLoadError(
                message: state.message,
                onRetry: () => context.read<ProjectDetailBloc>().add(
                  LoadProjectDetailEvent(projectId: projectId),
                ),
              );
            }

            if (state is ProjectDetailLoading || state is ProjectDetailInitial) {
              return ProjectDetailLoadingBody(
                title: initialProjectName,
                onBack: () => context.pop(),
              );
            }

            if (state is ProjectDetailLoaded) {
              final project = state.project;

              Future<void> onRefresh() async {
                context.read<ProjectDetailBloc>().add(
                  LoadProjectDetailEvent(projectId: projectId),
                );
                await context.read<ProjectDetailBloc>().stream.firstWhere(
                  (s) => s is ProjectDetailLoaded || s is ProjectDetailError,
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PostAuthHeader(
                    title: project.name,
                    leading: AppBackButton(onPressed: () => context.pop()),
                    trailing: MemberProjectActionMenu(
                      fundsHistoryOnly: true,
                      onSelected: (action) =>
                          ProjectDetailNavigation.handleMemberAction(
                            context,
                            project: project,
                            action: action,
                          ),
                    ),
                  ),
                  Expanded(
                    child: ColoredBox(
                      color: Colors.white,
                      child: RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: onRefresh,
                        child: CustomScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          slivers: [
                            SliverPadding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              sliver: SliverToBoxAdapter(
                                child: ProfileCompletedProjectDetailContent(
                                  project: project,
                                  onSendVffRequest: (member) =>
                                      sendMemberVffFromProjectDetail(
                                        context,
                                        member: member,
                                      ),
                                  sendingVffUserId: state.sendingVffUserId,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            return Center(
              child: AppText(
                AppStrings.errorGeneric,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.textBody),
              ),
            );
          },
        ),
      ),
    );
  }
}
