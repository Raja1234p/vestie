import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_shimmer_base.dart';

/// Skeleton for [LeaderViewSuccessVotesScreen] while active vote data loads.
class LeaderViewSuccessVotesScreenShimmer extends StatelessWidget {
  const LeaderViewSuccessVotesScreenShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _countdownSection(),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
            child: AppShimmer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _tallyCardsRow(),
                  SizedBox(height: 12.h),
                  AppShimmer.box(
                    width: double.infinity,
                    height: 44.h,
                    borderRadius: 12.r,
                  ),
                  SizedBox(height: 20.h),
                  AppShimmer.box(width: 140.w, height: 18.h, borderRadius: 4.r),
                  SizedBox(height: 10.h),
                  for (var i = 0; i < 5; i++) ...[
                    _memberRowPlaceholder(),
                    SizedBox(height: 8.h),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _countdownSection() {
    return Container(
      width: double.infinity,
      color: AppColors.purple100,
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
      child: AppShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppShimmer.box(width: 180.w, height: 14.h, borderRadius: 4.r),
            SizedBox(height: 10.h),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.neutral400),
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(child: _timerSegmentPlaceholder()),
                    VerticalDivider(
                      width: 1.w,
                      thickness: 1,
                      color: AppColors.neutral400,
                    ),
                    Expanded(child: _timerSegmentPlaceholder()),
                    VerticalDivider(
                      width: 1.w,
                      thickness: 1,
                      color: AppColors.neutral400,
                    ),
                    Expanded(child: _timerSegmentPlaceholder()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timerSegmentPlaceholder() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 14.h),
      child: Column(
        children: [
          AppShimmer.box(width: 40.w, height: 32.h, borderRadius: 4.r),
          SizedBox(height: 4.h),
          AppShimmer.box(width: 28.w, height: 13.h, borderRadius: 4.r),
        ],
      ),
    );
  }

  Widget _tallyCardsRow() {
    return Row(
      children: [
        Expanded(child: _tallyCardPlaceholder()),
        SizedBox(width: 8.w),
        Expanded(child: _tallyCardPlaceholder()),
        SizedBox(width: 8.w),
        Expanded(child: _tallyCardPlaceholder()),
      ],
    );
  }

  Widget _tallyCardPlaceholder() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 6.w),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.neutral500),
      ),
      child: Column(
        children: [
          AppShimmer.box(width: 56.w, height: 13.h, borderRadius: 4.r),
          SizedBox(height: 6.h),
          AppShimmer.box(width: 32.w, height: 30.h, borderRadius: 4.r),
        ],
      ),
    );
  }

  Widget _memberRowPlaceholder() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.neutral500),
      ),
      child: Row(
        children: [
          Expanded(
            child: AppShimmer.box(
              width: double.infinity,
              height: 16.h,
              borderRadius: 4.r,
            ),
          ),
          SizedBox(width: 12.w),
          AppShimmer.box(width: 72.w, height: 28.h, borderRadius: 20.r),
        ],
      ),
    );
  }
}
