import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/text/app_text.dart';

/// Member vote summary tiles (Figma My Borrow Request).
class MyBorrowMemberVotes extends StatelessWidget {
  final int upvotes;
  final int downvotes;

  const MyBorrowMemberVotes({
    super.key,
    required this.upvotes,
    required this.downvotes,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          AppStrings.myBorrowMemberVotesLabel,
          style: GoogleFonts.lato(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.projectDetailText,
          ),
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: _VoteTile(
                iconPath: AppAssets.voteThumbsUp,
                count: upvotes,
                backgroundColor: AppColors.green100,
                foregroundColor: AppColors.green900,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _VoteTile(
                iconPath: AppAssets.voteThumbsDown,
                count: downvotes,
                backgroundColor: AppColors.borrowVoteDownBg,
                foregroundColor: AppColors.red900,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColors.borrowPendingBannerBg,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: AppText(
            AppStrings.myBorrowPendingBanner,
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.borrowPendingBannerText,
            ),
          ),
        ),
      ],
    );
  }
}

class _VoteTile extends StatelessWidget {
  final String iconPath;
  final int count;
  final Color backgroundColor;
  final Color foregroundColor;

  const _VoteTile({
    required this.iconPath,
    required this.count,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            iconPath,
            width: 22.w,
            height: 22.w,
            colorFilter: ColorFilter.mode(foregroundColor, BlendMode.srcIn),
          ),
          SizedBox(width: 8.w),
          AppText(
            '$count',
            style: GoogleFonts.lato(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: foregroundColor,
            ),
          ),
        ],
      ),
    );
  }
}
