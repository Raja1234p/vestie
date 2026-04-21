import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_assets.dart';
import '../../constants/app_strings.dart';
import '../../theme/app_colors.dart';

/// Reusable Upvote / Downvote button pair.
/// Used in: BorrowRequestCard, and any future voting screen.
class AppVoteButtons extends StatelessWidget {
  final bool hasUpvoted;
  final bool hasDownvoted;
  final int upvotes;
  final int downvotes;
  final VoidCallback onUpvote;
  final VoidCallback onDownvote;

  const AppVoteButtons({
    super.key,
    required this.hasUpvoted,
    required this.hasDownvoted,
    required this.upvotes,
    required this.downvotes,
    required this.onUpvote,
    required this.onDownvote,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ── Downvote ──────────────────────────────────────────
        Expanded(
          child: _VoteButton(
            label: AppStrings.downvoteLabel,
            iconPath: AppAssets.iconThumbsDown,
            isActive: hasDownvoted,
            isPrimary: false,
            onTap: onDownvote,
          ),
        ),
        SizedBox(width: 10.w),
        // ── Upvote ────────────────────────────────────────────
        Expanded(
          child: _VoteButton(
            label: AppStrings.upvoteLabel,
            iconPath: AppAssets.iconThumbsUp,
            isActive: hasUpvoted,
            isPrimary: true,
            onTap: onUpvote,
          ),
        ),
      ],
    );
  }
}

// ── Private vote button ────────────────────────────────────────────────────────
class _VoteButton extends StatelessWidget {
  final String label;
  final String iconPath;
  final bool isActive;
  final bool isPrimary;
  final VoidCallback onTap;

  const _VoteButton({
    required this.label,
    required this.iconPath,
    required this.isActive,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isPrimary
        ? (isActive ? AppColors.purple700 : AppColors.grey1100)
        : Colors.transparent;
    final borderColor = isPrimary
        ? Colors.transparent
        : (isActive ? AppColors.red600 : AppColors.red600);
    final iconColor = isPrimary
        ? AppColors.neutral100
        : (isActive ? AppColors.red900 : AppColors.red900);
    final textColor = isPrimary ? AppColors.neutral100 : AppColors.red900;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 44.h,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(100.r),
          border: Border.all(color: borderColor, width: 1.5.w),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              iconPath,
              width: 16.w,
              height: 16.w,
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: GoogleFonts.lato(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
