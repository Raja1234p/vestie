import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/utils/app_snackbar.dart';
import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/common/app_shimmer.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/common/post_auth_header.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vestie/features/project_detail/domain/usecases/moderate_member_usecase.dart';
import 'package:vestie/features/project_detail/presentation/bloc/moderation_bloc.dart';
import 'package:vestie/features/project_detail/presentation/bloc/moderation_event.dart';
import 'package:vestie/features/project_detail/presentation/bloc/moderation_state.dart';
import 'package:vestie/features/project_detail/presentation/cubit/join_requests_cubit.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_detail_load_error.dart';
import '../widgets/join_request_card.dart';
import '../widgets/join_request_result_dialogs.dart';

/// Week 3 — `GET /projects/{id}/memberships/pending` + approve/reject actions.
class JoinRequestsScreen extends StatefulWidget {
  final String projectId;

  const JoinRequestsScreen({super.key, required this.projectId});

  @override
  State<JoinRequestsScreen> createState() => _JoinRequestsScreenState();
}

class _JoinRequestsScreenState extends State<JoinRequestsScreen> {
  String? _dialogMemberName;
  bool? _wasApproved;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => JoinRequestsCubit(
            listPending: ServiceLocator.instance.listPendingJoinRequestsUseCase,
            detailRepository: ServiceLocator.instance.projectDetailRepository,
          )..load(widget.projectId),
        ),
        BlocProvider(
          create: (_) => ModerationBloc(
            moderateMemberUseCase:
                ServiceLocator.instance.moderateMemberUseCase,
          ),
        ),
      ],
      child: BlocListener<ModerationBloc, ModerationState>(
        listener: (context, mState) {
          if (mState.isLoading) return;
          if (mState.failure != null) {
            AppSnackBar.showError(context, mState.failure!.message);
            return;
          }
          if (mState.isSuccess) {
            final name = _dialogMemberName ?? 'Member';
            if (_wasApproved == true) {
              showJoinRequestApprovedDialog(context, memberName: name);
            } else if (_wasApproved == false) {
              showJoinRequestDeclinedDialog(context, memberName: name);
            }
            _dialogMemberName = null;
            _wasApproved = null;
            context.read<JoinRequestsCubit>().load(widget.projectId);
          }
        },
        child: Scaffold(
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
                BlocBuilder<JoinRequestsCubit, JoinRequestsState>(
                  builder: (context, state) {
                    if (state is JoinRequestsLoading ||
                        state is JoinRequestsInitial) {
                      return const SliverFillRemaining(
                        child: JoinRequestsListShimmer(),
                      );
                    }
                    if (state is JoinRequestsError) {
                      return SliverFillRemaining(
                        child: ProjectDetailLoadError(
                          message: state.message,
                          onRetry: () => context
                              .read<JoinRequestsCubit>()
                              .load(widget.projectId),
                        ),
                      );
                    }
                    if (state is JoinRequestsLoaded && state.requests.isEmpty) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24.w),
                            child: AppText(
                              AppStrings.joinRequestsEmpty,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lato(
                                fontSize: 15.sp,
                                color: AppColors.textBody,
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    if (state is JoinRequestsLoaded) {
                      return SliverPadding(
                        padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 22.h),
                        sliver: SliverList.separated(
                          itemCount: state.requests.length,
                          separatorBuilder: (_, _) => SizedBox(height: 2.h),
                          itemBuilder: (_, i) {
                            final r = state.requests[i];
                            final username = r.username.isEmpty
                                ? '@member'
                                : '@${r.username}';
                            return JoinRequestCard(
                              initials: r.initials,
                              name: r.displayName,
                              username: username,
                              onAccept: () => _submit(
                                context,
                                membershipId: r.membershipId,
                                memberName: r.displayName,
                                approve: true,
                              ),
                              onDecline: () => _submit(
                                context,
                                membershipId: r.membershipId,
                                memberName: r.displayName,
                                approve: false,
                              ),
                            );
                          },
                        ),
                      );
                    }
                    return const SliverToBoxAdapter(child: SizedBox.shrink());
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit(
    BuildContext context, {
    required String membershipId,
    required String memberName,
    required bool approve,
  }) {
    if (membershipId.isEmpty) {
      AppSnackBar.showError(context, AppStrings.errorGeneric);
      return;
    }
    _dialogMemberName = memberName;
    _wasApproved = approve;
    context.read<ModerationBloc>().add(
          SubmitModerationActionEvent(
            projectId: widget.projectId,
            userId: membershipId,
            action: approve
                ? ModerationAction.approve
                : ModerationAction.reject,
          ),
        );
  }
}
