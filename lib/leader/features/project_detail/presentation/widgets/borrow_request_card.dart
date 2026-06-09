import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_toast.dart';
import 'package:vestie/core/widgets/common/app_avatar_circle.dart';
import 'package:vestie/core/widgets/common/app_vote_buttons.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/features/project_detail/domain/entities/borrow_request_entity.dart';
import 'package:vestie/features/project_detail/presentation/cubit/borrow_vote_cubit.dart';
import 'package:vestie/features/project_detail/presentation/cubit/borrow_vote_state.dart';
import 'borrow_request_decision_dialogs.dart';

enum BorrowRequestActionMode { vote, decision }

/// A single borrow request card with avatar, amount, vote counts, and buttons.
/// Each card manages its own BorrowVoteCubit internally.
class BorrowRequestCard extends StatelessWidget {
  final String projectId;
  final BorrowRequestEntity request;
  final BorrowRequestActionMode actionMode;
  final VoidCallback? onOpenMemberDetail;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  /// Called after a successful Agree/Disagree so parent lists can refresh counts.
  final VoidCallback? onVoteSuccess;

  /// When true, hides Agree/Disagree (e.g. viewer is the requester).
  final bool hideVoteActions;

  const BorrowRequestCard({
    super.key,
    required this.projectId,
    required this.request,
    this.actionMode = BorrowRequestActionMode.vote,
    this.onOpenMemberDetail,
    this.onAccept,
    this.onReject,
    this.onVoteSuccess,
    this.hideVoteActions = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BorrowVoteCubit(
        voteUseCase: ServiceLocator.instance.voteBorrowRequestUseCase,
        projectId: projectId,
        requestId: request.id,
        upvotes: request.upvotes,
        downvotes: request.downvotes,
        callerVote: request.callerVote,
      ),
      child: _BorrowRequestCardBody(
        request: request,
        actionMode: actionMode,
        hideVoteActions: hideVoteActions,
        onOpenMemberDetail: onOpenMemberDetail,
        onAccept: onAccept,
        onReject: onReject,
        onVoteSuccess: onVoteSuccess,
      ),
    );
  }
}

// ── Card body ─────────────────────────────────────────────────────────────────
class _BorrowRequestCardBody extends StatelessWidget {
  final BorrowRequestEntity request;
  final BorrowRequestActionMode actionMode;
  final bool hideVoteActions;
  final VoidCallback? onOpenMemberDetail;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onVoteSuccess;

  const _BorrowRequestCardBody({
    required this.request,
    required this.actionMode,
    this.hideVoteActions = false,
    this.onOpenMemberDetail,
    this.onAccept,
    this.onReject,
    this.onVoteSuccess,
  });

  String _fmt(double v) =>
      '\$${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',')}';

  bool get _showsVoteActions =>
      actionMode == BorrowRequestActionMode.vote && !hideVoteActions;

  bool get _showsDecisionActions => request.callerCanDecide;

  bool get _showsActionFooter => _showsVoteActions || _showsDecisionActions;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.fromLTRB(
        16.w,
        16.h,
        16.w,
        _showsActionFooter ? 16.h : 8.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.grey100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: tap → member detail (vote / decision buttons stay separate)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onOpenMemberDetail,
              borderRadius: BorderRadius.circular(12.r),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                child: Row(
                  children: [
                    AppAvatarCircle(initials: request.initials, size: 55.h),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            request.memberName,
                            style: GoogleFonts.lato(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.grey1100,
                            ),
                          ),
                          AppText(
                            request.loanType,
                            style: GoogleFonts.lato(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.grey1100,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),

          // ── Requested amount label ──────────────────────────
          AppText(
            AppStrings.requestedAmount,
            style: GoogleFonts.lato(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.grey800,
            ),
          ),
          // ── Amount + vote counts ────────────────────────────
          BlocBuilder<BorrowVoteCubit, BorrowVoteState>(
            builder: (context, state) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AppText(
                    _fmt(request.requestedAmount),
                    style: GoogleFonts.lato(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.grey1100,
                    ),
                  ),
                  const Spacer(),
                  _VoteCount(
                    count: state.upvotes,
                    isUpvote: true,
                    useThumbIcons:
                        actionMode == BorrowRequestActionMode.decision,
                  ),
                  SizedBox(width: 12.w),
                  _VoteCount(
                    count: state.downvotes,
                    isUpvote: false,
                    useThumbIcons:
                        actionMode == BorrowRequestActionMode.decision,
                  ),
                ],
              );
            },
          ),
          if (_showsActionFooter) SizedBox(height: 12.h),

          // ── Vote buttons ────────────────────────────────────
          if (_showsVoteActions)
            BlocBuilder<BorrowVoteCubit, BorrowVoteState>(
              builder: (context, state) {
                if (state.hasDownvoted) {
                  return _VoteStatusBanner(
                    message: AppStrings.downvotedStatusLabel,
                    color: AppColors.error,
                  );
                }
                if (state.hasUpvoted) {
                  return _VoteStatusBanner(
                    message: AppStrings.upvotedStatusLabel,
                    color: AppColors.success,
                  );
                }

                final cubit = context.read<BorrowVoteCubit>();
                return AppVoteButtons(
                  hasUpvoted: state.hasUpvoted,
                  hasDownvoted: state.hasDownvoted,
                  upvotes: state.upvotes,
                  downvotes: state.downvotes,
                  onUpvote: () async {
                    final voted = await showUpvoteBorrowRequestFlow(
                      context,
                      request,
                      onConfirmed: () async {
                        final error = await cubit.voteAgree();
                        if (!context.mounted) return false;
                        if (error != null) {
                          AppToast.showError(context, error);
                          return false;
                        }
                        return true;
                      },
                    );
                    if (!voted || !context.mounted) return;
                    onVoteSuccess?.call();
                  },
                  onDownvote: () async {
                    final voted = await showDownvoteBorrowRequestFlow(
                      context,
                      request,
                      onConfirmed: () async {
                        final error = await cubit.voteDisagree();
                        if (!context.mounted) return false;
                        if (error != null) {
                          AppToast.showError(context, error);
                          return false;
                        }
                        return true;
                      },
                    );
                    if (!voted || !context.mounted) return;
                    onVoteSuccess?.call();
                  },
                );
              },
            )
          else if (_showsDecisionActions)
            _DecisionButtons(onReject: onReject, onAccept: onAccept),
        ],
      ),
    );
  }
}

class _VoteStatusBanner extends StatelessWidget {
  final String message;
  final Color color;

  const _VoteStatusBanner({required this.message, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 40.h,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(100.r),
      ),
      alignment: Alignment.center,
      child: AppText(
        message,
        style: GoogleFonts.lato(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.surface,
        ),
      ),
    );
  }
}

class _DecisionButtons extends StatelessWidget {
  final VoidCallback? onReject;
  final VoidCallback? onAccept;

  const _DecisionButtons({this.onReject, this.onAccept});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 44.h,
            child: OutlinedButton(
              onPressed: onReject ?? () {},
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.red600, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100.r),
                ),
              ),
              child: AppText(
                AppStrings.rejectLabel,
                style: GoogleFonts.lato(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.red900,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: SizedBox(
            height: 44.h,
            child: ElevatedButton(
              onPressed: onAccept ?? () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.grey1200,
                foregroundColor: AppColors.surface,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100.r),
                ),
              ),
              child: AppText(
                AppStrings.acceptLabel,
                style: GoogleFonts.lato(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Vote count indicator ───────────────────────────────────────────────────────
class _VoteCount extends StatelessWidget {
  final int count;
  final bool isUpvote;
  final bool useThumbIcons;
  const _VoteCount({
    required this.count,
    required this.isUpvote,
    this.useThumbIcons = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconPath = useThumbIcons
        ? (isUpvote ? AppAssets.voteThumbsUp : AppAssets.voteThumbsDown)
        : (isUpvote ? AppAssets.voteArrowUp : AppAssets.voteArrowDown);

    return Row(
      children: [
        SvgPicture.asset(
          iconPath,
          width: 18.w,
          height: 18.w,
          colorFilter: ColorFilter.mode(
            isUpvote ? AppColors.badgeCompletedText : AppColors.red900,
            BlendMode.srcIn,
          ),
        ),
        SizedBox(width: 3.w),
        AppText(
          '$count',
          style: GoogleFonts.lato(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: isUpvote ? AppColors.badgeCompletedText : AppColors.red900,
          ),
        ),
      ],
    );
  }
}
