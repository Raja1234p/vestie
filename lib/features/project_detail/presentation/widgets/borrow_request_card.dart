import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/app_avatar_circle.dart';
import '../../../../core/widgets/common/app_vote_buttons.dart';
import '../../../../core/widgets/text/app_text.dart';
import '../../domain/entities/borrow_request_entity.dart';
import '../cubit/borrow_vote_cubit.dart';
import '../cubit/borrow_vote_state.dart';

enum BorrowRequestActionMode { vote, decision }

/// A single borrow request card with avatar, amount, vote counts, and buttons.
/// Each card manages its own BorrowVoteCubit internally.
class BorrowRequestCard extends StatelessWidget {
  final BorrowRequestEntity request;
  final VoidCallback? onArrowTap;
  final BorrowRequestActionMode actionMode;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const BorrowRequestCard({
    super.key,
    required this.request,
    this.onArrowTap,
    this.actionMode = BorrowRequestActionMode.vote,
    this.onAccept,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BorrowVoteCubit(
        upvotes: request.upvotes,
        downvotes: request.downvotes,
      ),
      child: _BorrowRequestCardBody(
        request: request,
        onArrowTap: onArrowTap,
        actionMode: actionMode,
        onAccept: onAccept,
        onReject: onReject,
      ),
    );
  }
}

// ── Card body ─────────────────────────────────────────────────────────────────
class _BorrowRequestCardBody extends StatelessWidget {
  final BorrowRequestEntity request;
  final VoidCallback? onArrowTap;
  final BorrowRequestActionMode actionMode;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const _BorrowRequestCardBody({
    required this.request,
    this.onArrowTap,
    required this.actionMode,
    this.onAccept,
    this.onReject,
  });

  String _fmt(double v) =>
      '\$${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',')}';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.grey200,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: avatar + name + loan type + arrow ──────
          Row(
            children: [
              AppAvatarCircle(initials: request.initials,size: 55.h,),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      request.memberName,
                      style: GoogleFonts.lato(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.grey1100,
                      ),
                    ),
                    AppText(
                      request.loanType,
                      style: GoogleFonts.lato(
                        fontSize: 13.sp,
                        color: AppColors.textBody,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onArrowTap,
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textBody,
                  size: 22.w,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // ── Requested amount label ──────────────────────────
          AppText(
            AppStrings.requestedAmount,
            style: GoogleFonts.lato(
              fontSize: 14.sp,
              color: AppColors.textBody,
            ),
          ),
          SizedBox(height: 4.h),

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
          SizedBox(height: 12.h),

          // ── Vote buttons ────────────────────────────────────
          if (actionMode == BorrowRequestActionMode.vote)
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
                  onUpvote: cubit.toggleUpvote,
                  onDownvote: cubit.toggleDownvote,
                );
              },
            )
          else
            _DecisionButtons(
              onReject: onReject,
              onAccept: onAccept,
            ),
        ],
      ),
    );
  }
}

class _VoteStatusBanner extends StatelessWidget {
  final String message;
  final Color color;

  const _VoteStatusBanner({
    required this.message,
    required this.color,
  });

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
        ? (isUpvote ? AppAssets.iconThumbsUp : AppAssets.iconThumbsDown)
        : (isUpvote ? AppAssets.upWordArrow : AppAssets.downWordArrow);

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
