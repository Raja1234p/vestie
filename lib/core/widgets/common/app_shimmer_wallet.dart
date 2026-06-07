import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_dimens.dart';
import '../../theme/app_colors.dart';
import 'app_shimmer_base.dart';

/// Wallet tab initial load — balance, actions, recent activity panel.
class WalletTabShimmer extends StatelessWidget {
  const WalletTabShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppShimmer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
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
                          SizedBox(height: 8.h),
                          AppShimmer.box(
                            width: double.infinity,
                            height: 44.h,
                            borderRadius: 6.r,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12.w),
                    AppShimmer.box(
                      width: 88.w,
                      height: 56.h,
                      borderRadius: 10.r,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: AppShimmer.box(
                        width: double.infinity,
                        height: 48.h,
                        borderRadius: 24.r,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: AppShimmer.box(
                        width: double.infinity,
                        height: 48.h,
                        borderRadius: 24.r,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadius.r16),
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 16.h, bottom: 8.h),
                  child: AppShimmer(
                    child: Row(
                      children: [
                        AppShimmer.box(
                          width: 120.w,
                          height: 18.h,
                          borderRadius: 4.r,
                        ),
                        const Spacer(),
                        AppShimmer.box(
                          width: 72.w,
                          height: 16.h,
                          borderRadius: 4.r,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Expanded(
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(bottom: 16.h),
                    itemCount: 4,
                    separatorBuilder: (context, index) =>
                        SizedBox(height: AppDimens.walletTransactionRowGap),
                    itemBuilder: (context, index) =>
                        const WalletRecentActivityRowShimmer(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Single recent-activity row skeleton (matches [AppTransactionItem] card).
class WalletRecentActivityRowShimmer extends StatelessWidget {
  const WalletRecentActivityRowShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.neutral500),
        ),
        child: Row(
          children: [
            AppShimmer.box(width: 40.w, height: 40.w, borderRadius: 20.r),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppShimmer.box(width: 140.w, height: 14.h, borderRadius: 4.r),
                  SizedBox(height: 6.h),
                  AppShimmer.box(width: 90.w, height: 12.h, borderRadius: 4.r),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            AppShimmer.box(width: 56.w, height: 16.h, borderRadius: 4.r),
          ],
        ),
      ),
    );
  }
}
