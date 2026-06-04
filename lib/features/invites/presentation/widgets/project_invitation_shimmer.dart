import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/widgets/common/app_shimmer.dart';

/// Skeleton for invite preview API load (hero, title, stats, description).
class ProjectInvitationBodyShimmer extends StatelessWidget {
  const ProjectInvitationBodyShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
            SizedBox(height: 58.h),
            Center(
              child: AppShimmer.box(
                width: 150.w,
                height: 150.w,
                borderRadius: 75.r,
              ),
            ),
            SizedBox(height: AppDimens.v16),
            AppShimmer.box(
              width: 220.w,
              height: 28.h,
              borderRadius: 6.r,
            ),
            SizedBox(height: AppDimens.v28),
            AppShimmer.box(
              width: double.infinity,
              height: 1.h,
              borderRadius: 0,
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(child: _statColumnShimmer()),
                Expanded(child: _statColumnShimmer()),
                Expanded(child: _statColumnShimmer()),
              ],
            ),
            SizedBox(height: 20.h),
            AppShimmer.box(
              width: double.infinity,
              height: 1.h,
              borderRadius: 0,
            ),
            SizedBox(height: 16.h),
            Align(
              alignment: Alignment.centerLeft,
              child: AppShimmer.box(width: 100.w, height: 12.h, borderRadius: 4.r),
            ),
            SizedBox(height: 8.h),
            AppShimmer.box(
              width: double.infinity,
              height: 13.h,
              borderRadius: 4.r,
            ),
            SizedBox(height: 8.h),
            AppShimmer.box(
              width: double.infinity,
              height: 13.h,
              borderRadius: 4.r,
            ),
            SizedBox(height: AppDimens.v24),
          ],
      ),
    );
  }
}

/// Footer skeleton content — wrapped by [FlowScreenFooter] on the screen.
class ProjectInvitationFooterShimmerContent extends StatelessWidget {
  const ProjectInvitationFooterShimmerContent({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppShimmer.box(
            width: double.infinity,
            height: 56.h,
            borderRadius: 999.r,
          ),
          SizedBox(height: 16.h),
          Center(
            child: AppShimmer.box(width: 120.w, height: 18.h, borderRadius: 4.r),
          ),
        ],
      ),
    );
  }
}

Widget _statColumnShimmer() {
  return Column(
    children: [
      AppShimmer.box(width: 72.w, height: 12.h, borderRadius: 4.r),
      SizedBox(height: 8.h),
      AppShimmer.box(width: 56.w, height: 20.h, borderRadius: 4.r),
    ],
  );
}

