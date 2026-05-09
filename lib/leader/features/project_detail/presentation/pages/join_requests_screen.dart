import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/common/app_loader.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/common/post_auth_header.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/utils/app_snackbar.dart';
import 'package:vestie/features/projects/presentation/bloc/project_detail_bloc.dart';
import 'package:vestie/features/project_detail/presentation/bloc/moderation_bloc.dart';
import 'package:vestie/features/project_detail/presentation/bloc/moderation_event.dart';
import 'package:vestie/features/project_detail/presentation/bloc/moderation_state.dart';
import 'package:vestie/features/project_detail/domain/usecases/moderate_member_usecase.dart';
import '../widgets/join_request_card.dart';
import '../widgets/join_request_result_dialogs.dart';

class JoinRequestsScreen extends StatelessWidget {
  final String projectId;

  const JoinRequestsScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              ServiceLocator.instance.projectDetailBloc
                ..add(LoadProjectDetailEvent(projectId: projectId)),
        ),
        BlocProvider(create: (_) => ServiceLocator.instance.moderationBloc),
      ],
      child: BlocListener<ModerationBloc, ModerationState>(
        listener: (context, mState) {
          if (mState.isSuccess) {
            context.read<ProjectDetailBloc>().add(
              LoadProjectDetailEvent(projectId: projectId),
            );
          } else if (mState.failure != null) {
            AppSnackBar.showError(context, mState.failure!.message);
          }
        },
        child: BlocBuilder<ProjectDetailBloc, ProjectDetailState>(
          builder: (context, state) {
            final isLoading =
                state is ProjectDetailLoading || state is ProjectDetailInitial;
            final requests = state is ProjectDetailLoaded
                ? state.project.members
                      .where((m) => m.status.toLowerCase().contains('pending'))
                      .toList()
                : [];

            return Scaffold(
              backgroundColor: Colors.transparent,
              body: PostAuthGradientBackground(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: PostAuthHeader(
                        title: AppStrings.menuJoinRequests,
                        leading: AppBackButton(onPressed: () => context.pop()),
                      ),
                    ),
                    if (isLoading)
                      const SliverFillRemaining(
                        child: Center(child: AppLoader()),
                      ),
                    if (!isLoading && requests.isEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.only(top: 24.h),
                          child: Center(
                            child: AppText(
                              AppStrings.emptyData,
                              style: GoogleFonts.lato(
                                fontSize: 15.sp,
                                color: AppColors.textBody,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    if (!isLoading && requests.isNotEmpty)
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 22.h),
                        sliver: SliverList.separated(
                          itemBuilder: (_, i) {
                            final m = requests[i];
                            final username = m.username.isEmpty
                                ? '@member'
                                : '@${m.username}';
                            return JoinRequestCard(
                              initials: m.initials,
                              name: m.name,
                              username: username,
                              onAccept: () {
                                final membershipId = m.membershipId.isNotEmpty
                                    ? m.membershipId
                                    : m.id;
                                context.read<ModerationBloc>().add(
                                  SubmitModerationActionEvent(
                                    projectId: projectId,
                                    userId: membershipId,
                                    action: ModerationAction.approve,
                                  ),
                                );
                                showJoinRequestApprovedDialog(
                                  context,
                                  memberName: m.name,
                                );
                              },
                              onDecline: () {
                                final membershipId = m.membershipId.isNotEmpty
                                    ? m.membershipId
                                    : m.id;
                                context.read<ModerationBloc>().add(
                                  SubmitModerationActionEvent(
                                    projectId: projectId,
                                    userId: membershipId,
                                    action: ModerationAction.reject,
                                  ),
                                );
                                showJoinRequestDeclinedDialog(
                                  context,
                                  memberName: m.name,
                                );
                              },
                            );
                          },
                          separatorBuilder: (_, _) => SizedBox(height: 2.h),
                          itemCount: requests.length,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
