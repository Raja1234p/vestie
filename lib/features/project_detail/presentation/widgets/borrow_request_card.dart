import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/app_avatar_circle.dart';
import '../../../../core/widgets/common/app_vote_buttons.dart';
import '../../domain/entities/borrow_request_entity.dart';
import '../cubit/borrow_vote_cubit.dart';
import '../cubit/borrow_vote_state.dart';

/// A single borrow request card with avatar, amount, vote counts, and buttons.
/// Each card manages its own BorrowVoteCubit internally.
class BorrowRequestCard extends StatelessWidget {
  final BorrowRequestEntity request;
  final VoidCallback? onArrowTap;

  const BorrowRequestCard({
    super.key,
    required this.request,
    this.onArrowTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BorrowVoteCubit(
        upvotes: request.upvotes,
        downvotes: request.downvotes,
      ),
      child: _BorrowRequestCardBody(request: request, onArrowTap: onArrowTap),
    );
  }
}

// ── Card body ─────────────────────────────────────────────────────────────────
class _BorrowRequestCardBody extends StatelessWidget {
  final BorrowRequestEntity request;
  final VoidCallback? onArrowTap;

  const _BorrowRequestCardBody({required this.request, this.onArrowTap});

  String _fmt(double v) =>
      '\$${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',')}';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: avatar + name + loan type + arrow ──────
          Row(
            children: [
              AppAvatarCircle(initials: request.initials),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.memberName,
                      style: GoogleFonts.lato(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.grey1100,
                      ),
                    ),
                    Text(
                      request.loanType,
                      style: GoogleFonts.lato(
                        fontSize: 12.sp,
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
          Text(
            AppStrings.requestedAmount,
            style: GoogleFonts.lato(
              fontSize: 12.sp,
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
                  Text(
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
                  ),
                  SizedBox(width: 12.w),
                  _VoteCount(
                    count: state.downvotes,
                    isUpvote: false,
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 12.h),

          // ── Vote buttons ────────────────────────────────────
          BlocBuilder<BorrowVoteCubit, BorrowVoteState>(
            builder: (context, state) {
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
          ),
        ],
      ),
    );
  }
}

// ── Vote count indicator ───────────────────────────────────────────────────────
class _VoteCount extends StatelessWidget {
  final int count;
  final bool isUpvote;
  const _VoteCount({required this.count, required this.isUpvote});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isUpvote ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
          size: 14.w,
          color: isUpvote ? AppColors.success : AppColors.error,
        ),
        SizedBox(width: 3.w),
        Text(
          '$count',
          style: GoogleFonts.lato(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: isUpvote ? AppColors.success : AppColors.error,
          ),
        ),
      ],
    );
  }
}
