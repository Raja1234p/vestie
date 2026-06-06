import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_shimmer.dart';

/// Search bar skeleton — matches [DiscoverSearchBar] (56.h pill, 16.w inset).
class DiscoverSearchBarShimmer extends StatelessWidget {
  const DiscoverSearchBarShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final height = 56.h;
    final radius = height / 2;

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      child: AppShimmer(
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: AppColors.border,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: AppColors.inputFieldBorder),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              Expanded(
                child: AppShimmer.box(
                  width: 140.w,
                  height: 14.h,
                  borderRadius: 4.r,
                ),
              ),
              AppShimmer.box(width: 20.w, height: 20.w, borderRadius: 10.r),
            ],
          ),
        ),
      ),
    );
  }
}

/// Filter chips skeleton — matches [DiscoverFilterRow] horizontal chip row.
class DiscoverFilterRowShimmer extends StatelessWidget {
  const DiscoverFilterRowShimmer({super.key});

  static const _chipWidths = [36.0, 88.0, 92.0, 96.0];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: AppShimmer(
        child: Row(
          children: [
            SizedBox(width: 10.w),
            for (final width in _chipWidths)
              Container(
                margin: EdgeInsets.only(right: 8.w),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(color: AppColors.purple300, width: 1),
                ),
                child: AppShimmer.box(
                  width: width.w,
                  height: 14.h,
                  borderRadius: 4.r,
                ),
              ),
            SizedBox(width: 10.w),
          ],
        ),
      ),
    );
  }
}
