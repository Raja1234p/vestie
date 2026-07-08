import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_shimmer_base.dart';
import 'package:vestie/core/widgets/common/flow_screen_footer.dart';
import 'package:vestie/core/widgets/common/post_auth_flow_sub_header.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';

/// Skeleton for [InvestmentDistributionScreen] while preview API loads.
class InvestmentDistributionScreenShimmer extends StatelessWidget {
  const InvestmentDistributionScreenShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      resizeToAvoidBottomInset: false,
      body: PostAuthGradientBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PostAuthFlowSubHeader(
              title: AppStrings.investmentDistributionScreenTitle,
              onBack: () => context.pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                padding: AppDimens.postAuthFlowScrollPadding,
                child: AppShimmer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppShimmer.box(
                        width: 120.w,
                        height: 18.h,
                        borderRadius: 4.r,
                      ),
                      SizedBox(height: 4.h),
                      AppShimmer.box(
                        width: 180.w,
                        height: 36.h,
                        borderRadius: 6.r,
                      ),
                      SizedBox(height: 4.h),
                      AppShimmer.box(
                        width: 200.w,
                        height: 14.h,
                        borderRadius: 4.r,
                      ),
                      SizedBox(height: 12.h),
                      AppShimmer.box(
                        width: double.infinity,
                        height: 40.h,
                        borderRadius: 12.r,
                      ),
                      SizedBox(height: 20.h),
                      AppShimmer.box(
                        width: 100.w,
                        height: 16.h,
                        borderRadius: 4.r,
                      ),
                      SizedBox(height: 12.h),
                      _breakdownTablePlaceholder(),
                    ],
                  ),
                ),
              ),
            ),
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

  Widget _breakdownTablePlaceholder() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.neutral500),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: AppColors.purple100,
            height: 40.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Row(
              children: List.generate(
                4,
                (_) => Expanded(
                  child: AppShimmer.box(
                    width: 48.w,
                    height: 10.h,
                    borderRadius: 4.r,
                  ),
                ),
              ),
            ),
          ),
          Divider(height: 1, thickness: 1, color: AppColors.neutral500),
          for (var i = 0; i < 4; i++) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              child: Row(
                children: List.generate(
                  4,
                  (_) => Expanded(
                    child: AppShimmer.box(
                      width: 56.w,
                      height: 12.h,
                      borderRadius: 4.r,
                    ),
                  ),
                ),
              ),
            ),
            if (i < 3)
              Divider(
                height: 1,
                thickness: 1,
                color: AppColors.neutral500.withValues(alpha: 0.5),
              ),
          ],
        ],
      ),
    );
  }
}
