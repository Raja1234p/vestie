import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/app_back_button.dart';
import '../../../../core/widgets/common/app_loader.dart';
import '../../../../core/widgets/common/post_auth_gradient_background.dart';
import '../../../../core/widgets/common/post_auth_header.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../projects/presentation/bloc/project_detail_bloc.dart';
import '../bloc/moderation_bloc.dart';
import '../bloc/moderation_event.dart';
import '../bloc/moderation_state.dart';
import '../../domain/usecases/moderate_member_usecase.dart';
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
          create: (_) => ServiceLocator.instance.projectDetailBloc..add(LoadProjectDetailEvent(projectId: projectId)),
        ),
        BlocProvider(
          create: (_) => ServiceLocator.instance.moderationBloc,
        ),
      ],
      child: BlocListener<ModerationBloc, ModerationState>(
        listener: (context, mState) {
          if (mState.isSuccess) {
            context.read<ProjectDetailBloc>().add(LoadProjectDetailEvent(projectId: projectId));
          } else if (mState.failure != null) {
            AppSnackBar.showError(context, mState.failure!.message);
          }
        },
        child: BlocBuilder<ProjectDetailBloc, ProjectDetailState>(
          builder: (context, state) {
            final isLoading = state is ProjectDetailLoading || state is ProjectDetailInitial;
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
                        leading: AppBackButton(
                          onPressed: () => context.pop(),
                        ),
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
                            child: Text(
                              AppStrings.emptyData,
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
                            final username = m.username.isEmpty ? '@member' : '@${m.username}';
                            return JoinRequestCard(
                              initials: m.initials,
                              name: m.name,
                              username: username,
                              onAccept: () {
                                context.read<ModerationBloc>().add(SubmitModerationActionEvent(
                                  projectId: projectId,
                                  userId: m.id,
                                  action: ModerationAction.approve,
                                ));
                                showJoinRequestApprovedDialog(
                                  context,
                                  memberName: m.name,
                                );
                              },
                              onDecline: () {
                                context.read<ModerationBloc>().add(SubmitModerationActionEvent(
                                  projectId: projectId,
                                  userId: m.id,
                                  action: ModerationAction.reject,
                                ));
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
