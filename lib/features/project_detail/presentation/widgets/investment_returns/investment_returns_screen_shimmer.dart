import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/common/app_shimmer_base.dart';
import 'package:vestie/core/widgets/common/flow_screen_footer.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/common/post_auth_header.dart';

/// Skeleton for [InvestmentReturnsScreenShell] while distributions load.
class InvestmentReturnsScreenShimmer extends StatelessWidget {
  final String title;
  final bool showFooter;

  const InvestmentReturnsScreenShimmer({
    super.key,
    required this.title,
    this.showFooter = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: PostAuthGradientBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PostAuthHeader(
              title: title,
              leading: AppBackButton(onPressed: () => context.pop()),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: AppShimmer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppShimmer.box(
                                  width: 140.w,
                                  height: 14.h,
                                  borderRadius: 4.r,
                                ),
                                SizedBox(height: 8.h),
                                AppShimmer.box(
                                  width: 160.w,
                                  height: 36.h,
                                  borderRadius: 6.r,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 12.w),
                          AppShimmer.box(
                            width: 132.w,
                            height: 56.h,
                            borderRadius: 12.r,
                          ),
                        ],
                      ),
                      SizedBox(height: 28.h),
                      AppShimmer.box(
                        width: 160.w,
                        height: 18.h,
                        borderRadius: 4.r,
                      ),
                      SizedBox(height: 12.h),
                      for (var i = 0; i < 3; i++) ...[
                        _distributionCardPlaceholder(),
                        SizedBox(height: 12.h),
                      ],
                      SizedBox(height: showFooter ? 16.h : 32.h),
                    ],
                  ),
                ),
              ),
            ),
            if (showFooter)
              FlowScreenFooter(
                child: AppShimmer(
                  child: AppShimmer.box(
                    width: double.infinity,
                    height: 48.h,
                    borderRadius: 100.r,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _distributionCardPlaceholder() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.neutral500),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: AppColors.grey100,
            padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppShimmer.box(width: 120.w, height: 16.h, borderRadius: 4.r),
                SizedBox(height: 6.h),
                AppShimmer.box(width: 90.w, height: 14.h, borderRadius: 4.r),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: AppColors.neutral500),
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 14.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppShimmer.box(
                        width: 100.w,
                        height: 14.h,
                        borderRadius: 4.r,
                      ),
                      SizedBox(height: 6.h),
                      AppShimmer.box(
                        width: 80.w,
                        height: 20.h,
                        borderRadius: 4.r,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppShimmer.box(
                        width: 80.w,
                        height: 14.h,
                        borderRadius: 4.r,
                      ),
                      SizedBox(height: 6.h),
                      AppShimmer.box(
                        width: 70.w,
                        height: 20.h,
                        borderRadius: 4.r,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
