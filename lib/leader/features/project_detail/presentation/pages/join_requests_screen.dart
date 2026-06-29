import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/presentation/paginated_scroll_listener.dart';
import 'package:vestie/core/presentation/widgets/list_load_more_footer.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/navigation/success_dialog_navigation.dart';
import 'package:vestie/core/widgets/common/app_toast.dart';
import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/common/app_shimmer.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/common/post_auth_header.dart';
import 'package:vestie/features/project_detail/domain/usecases/moderate_member_usecase.dart';
import 'package:vestie/features/project_detail/presentation/bloc/moderation_bloc.dart';
import 'package:vestie/features/project_detail/presentation/bloc/moderation_event.dart';
import 'package:vestie/features/project_detail/presentation/bloc/moderation_state.dart';
import 'package:vestie/features/project_detail/presentation/cubit/join_requests_cubit.dart';
import 'package:vestie/features/project_detail/presentation/widgets/borrow_requests_empty_state.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_detail_load_error.dart';
import '../widgets/join_request_card.dart';
import '../widgets/join_request_result_dialogs.dart';

/// Week 3 — `GET /projects/{id}/memberships/pending` + approve/reject actions.
class JoinRequestsScreen extends StatefulWidget {
  final String projectId;
  final Future<void> Function()? onRefreshProjectDetail;

  const JoinRequestsScreen({
    super.key,
    required this.projectId,
    this.onRefreshProjectDetail,
  });

  @override
  State<JoinRequestsScreen> createState() => _JoinRequestsScreenState();
}

class _JoinRequestsScreenState extends State<JoinRequestsScreen> {
  String? _dialogMemberName;
  bool? _wasApproved;
  String? _actingMembershipId;
  bool? _actingIsApprove;
  bool _isSyncingAfterModeration = false;
  final ScrollController _scrollController = ScrollController();
  PaginatedScrollListener? _scrollListener;

  @override
  void initState() {
    super.initState();
    _scrollListener = PaginatedScrollListener(
      controller: _scrollController,
      onLoadMore: () {
        if (!mounted) return;
        context.read<JoinRequestsCubit>().loadMore();
      },
    );
  }

  @override
  void dispose() {
    _scrollListener?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _syncAfterModeration(BuildContext context) async {
    setState(() => _isSyncingAfterModeration = true);
    try {
      await widget.onRefreshProjectDetail?.call();
      if (!context.mounted) return;
      await context.read<JoinRequestsCubit>().load(widget.projectId);
    } finally {
      if (mounted) {
        setState(() => _isSyncingAfterModeration = false);
      }
    }
  }

  Future<void> _handleModerationSuccess(BuildContext context) async {
    await _syncAfterModeration(context);
    if (!mounted) return;
    setState(() {
      _actingMembershipId = null;
      _actingIsApprove = null;
    });
    if (!context.mounted) return;
    await _onModerationComplete(context);
  }

  Future<void> _onModerationComplete(BuildContext context) async {
    final name = _dialogMemberName ?? 'Member';
    final wasApproved = _wasApproved;

    _dialogMemberName = null;
    _wasApproved = null;
    context.read<ModerationBloc>().add(const ResetModerationStateEvent());

    if (wasApproved == true) {
      await showJoinRequestApprovedDialog(
        context,
        memberName: name,
        onOk: popDialogAction(context),
      );
    } else if (wasApproved == false) {
      await showJoinRequestDeclinedDialog(
        context,
        memberName: name,
        onOk: popDialogAction(context),
      );
    } else {
      return;
    }

    if (!context.mounted) return;
    context.read<JoinRequestsCubit>().load(widget.projectId);
  }

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
        listenWhen: (prev, curr) =>
            prev.isLoading != curr.isLoading ||
            (prev.isSuccess != curr.isSuccess && curr.isSuccess) ||
            (prev.failure != curr.failure && curr.failure != null),
        listener: (context, mState) {
          if (mState.isLoading) return;

          if (mState.failure != null) {
            setState(() {
              _actingMembershipId = null;
              _actingIsApprove = null;
            });
            AppToast.showError(context, mState.failure!.message);
            context.read<ModerationBloc>().add(
              const ResetModerationStateEvent(),
            );
            return;
          }

          if (mState.isSuccess) {
            _handleModerationSuccess(context);
          }
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: PostAuthGradientBackground(
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: PostAuthHeader(
                    title: AppStrings.menuJoinRequests,
                    leading: AppBackButton(onPressed: () => context.pop()),
                  ),
                ),
                BlocBuilder<ModerationBloc, ModerationState>(
                  builder: (context, moderation) {
                    return BlocBuilder<JoinRequestsCubit, JoinRequestsState>(
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
                        if (state is JoinRequestsLoaded &&
                            state.requests.isEmpty) {
                          return const SliverFillRemaining(
                            hasScrollBody: false,
                            child: BorrowRequestsEmptyState(
                              centered: true,
                              title: AppStrings.joinRequestsEmptyTitle,
                            ),
                          );
                        }
                        if (state is JoinRequestsLoaded) {
                          final isBusy =
                              moderation.isLoading || _isSyncingAfterModeration;
                          return SliverPadding(
                            padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 22.h),
                            sliver: SliverList.separated(
                              itemCount: state.requests.length + 1,
                              separatorBuilder: (_, i) {
                                if (i >= state.requests.length - 1) {
                                  return const SizedBox.shrink();
                                }
                                return SizedBox(height: 2.h);
                              },
                              itemBuilder: (_, i) {
                                if (i == state.requests.length) {
                                  return ListLoadMoreFooter(
                                    loadingMore: state.loadingMore,
                                  );
                                }
                                final r = state.requests[i];
                                final username = r.username.isEmpty
                                    ? '@member'
                                    : '@${r.username}';
                                final isThisCard =
                                    _actingMembershipId == r.membershipId;
                                return JoinRequestCard(
                                  initials: r.initials,
                                  photoUrl: r.photoUrl,
                                  name: r.displayName,
                                  username: username,
                                  isAcceptLoading:
                                      isBusy &&
                                      isThisCard &&
                                      _actingIsApprove == true,
                                  isDeclineLoading:
                                      isBusy &&
                                      isThisCard &&
                                      _actingIsApprove == false,
                                  onAccept: isBusy
                                      ? null
                                      : () => _submit(
                                          context,
                                          membershipId: r.membershipId,
                                          memberName: r.displayName,
                                          approve: true,
                                        ),
                                  onDecline: isBusy
                                      ? null
                                      : () => _submit(
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
                        return const SliverToBoxAdapter(
                          child: SizedBox.shrink(),
                        );
                      },
                    );
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
      AppToast.showError(context, AppStrings.errorGeneric);
      return;
    }
    setState(() {
      _actingMembershipId = membershipId;
      _actingIsApprove = approve;
    });
    _dialogMemberName = memberName;
    _wasApproved = approve;
    context.read<ModerationBloc>().add(
      SubmitModerationActionEvent(
        projectId: widget.projectId,
        userId: membershipId,
        action: approve ? ModerationAction.approve : ModerationAction.reject,
      ),
    );
  }
}
