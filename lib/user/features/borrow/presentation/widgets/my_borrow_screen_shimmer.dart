import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_shimmer.dart';

import '../models/my_borrow_content_kind.dart';

/// My Borrow screen skeleton — matches loaded layout (Figma post-auth flow).
class MyBorrowScreenShimmer extends StatelessWidget {
  const MyBorrowScreenShimmer({super.key, required this.kind});

  final MyBorrowContentKind kind;

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SingleChildScrollView(
        padding: AppDimens.postAuthFlowScrollPadding,
        child: switch (kind) {
          MyBorrowContentKind.approved => const _MyBorrowApprovedShimmerBody(),
          MyBorrowContentKind.pending => const _MyBorrowPendingShimmerBody(),
          MyBorrowContentKind.historyOnly => const _MyBorrowHistoryShimmerBody(),
          MyBorrowContentKind.empty => const _MyBorrowEmptyShimmerBody(),
          MyBorrowContentKind.loading => const _MyBorrowLoadingShimmerBody(),
        },
      ),
    );
  }
}

/// Pinned footer CTA skeleton — shown while My Borrow loads.
class MyBorrowFooterShimmer extends StatelessWidget {
  const MyBorrowFooterShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: AppShimmer.box(
        width: double.infinity,
        height: 52.h,
        borderRadius: 12.r,
      ),
    );
  }
}

class _MyBorrowLoadingShimmerBody extends StatelessWidget {
  const _MyBorrowLoadingShimmerBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppShimmer.box(width: 130.w, height: 18.h, borderRadius: 4.r),
        SizedBox(height: AppDimens.v10),
        AppShimmer.box(width: 200.w, height: 36.h, borderRadius: 6.r),
        SizedBox(height: AppDimens.v24),
        AppShimmer.box(width: 110.w, height: 16.h, borderRadius: 4.r),
        SizedBox(height: AppDimens.v10),
        const _MyBorrowBreakdownCardShimmer(),
      ],
    );
  }
}

class _MyBorrowApprovedShimmerBody extends StatelessWidget {
  const _MyBorrowApprovedShimmerBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppShimmer.box(width: 130.w, height: 18.h, borderRadius: 4.r),
        SizedBox(height: AppDimens.v8),
        AppShimmer.box(width: 220.w, height: 44.h, borderRadius: 6.r),
        SizedBox(height: AppDimens.v24),
        AppShimmer.box(width: 110.w, height: 16.h, borderRadius: 4.r),
        SizedBox(height: AppDimens.v10),
        const _MyBorrowBreakdownCardShimmer(),
      ],
    );
  }
}

class _MyBorrowPendingShimmerBody extends StatelessWidget {
  const _MyBorrowPendingShimmerBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppShimmer.box(width: 130.w, height: 18.h, borderRadius: 4.r),
        SizedBox(height: AppDimens.v10),
        AppShimmer.box(width: 180.w, height: 32.h, borderRadius: 6.r),
        SizedBox(height: AppDimens.v20),
        AppShimmer.box(width: 150.w, height: 18.h, borderRadius: 4.r),
        SizedBox(height: AppDimens.v10),
        Row(
          children: [
            Expanded(
              child: AppShimmer.box(
                width: double.infinity,
                height: 52.h,
                borderRadius: 14.r,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: AppShimmer.box(
                width: double.infinity,
                height: 52.h,
                borderRadius: 14.r,
              ),
            ),
          ],
        ),
        SizedBox(height: AppDimens.v12),
        AppShimmer.box(width: double.infinity, height: 44.h, borderRadius: 12.r),
        SizedBox(height: AppDimens.v20),
        AppShimmer.box(width: 120.w, height: 18.h, borderRadius: 4.r),
        SizedBox(height: AppDimens.v10),
        const _MyBorrowHistoryRowShimmer(),
        SizedBox(height: AppDimens.v10),
        const _MyBorrowHistoryRowShimmer(),
      ],
    );
  }
}

class _MyBorrowHistoryShimmerBody extends StatelessWidget {
  const _MyBorrowHistoryShimmerBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppShimmer.box(width: 120.w, height: 18.h, borderRadius: 4.r),
        SizedBox(height: AppDimens.v10),
        const _MyBorrowHistoryRowShimmer(),
        SizedBox(height: AppDimens.v10),
        const _MyBorrowHistoryRowShimmer(),
        SizedBox(height: AppDimens.v10),
        const _MyBorrowHistoryRowShimmer(),
      ],
    );
  }
}

class _MyBorrowEmptyShimmerBody extends StatelessWidget {
  const _MyBorrowEmptyShimmerBody();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 48.h),
      child: Column(
        children: [
          AppShimmer.box(width: 120.w, height: 120.w, borderRadius: 60.r),
          SizedBox(height: AppDimens.v20),
          AppShimmer.box(width: 200.w, height: 22.h, borderRadius: 4.r),
          SizedBox(height: AppDimens.v8),
          AppShimmer.box(width: 260.w, height: 16.h, borderRadius: 4.r),
        ],
      ),
    );
  }
}

class _MyBorrowBreakdownCardShimmer extends StatelessWidget {
  const _MyBorrowBreakdownCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        AppDimens.p14,
        AppDimens.v14,
        AppDimens.p14,
        AppDimens.v14,
      ),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(AppRadius.r14),
        border: Border.all(color: AppColors.neutral400),
      ),
      child: Column(
        children: [
          _summaryRowShimmer(width: 0.55),
          SizedBox(height: AppDimens.v14),
          _summaryRowShimmer(width: 0.5),
          SizedBox(height: AppDimens.v14),
          Container(height: 1, color: AppColors.neutral400),
          SizedBox(height: AppDimens.v14),
          _summaryRowShimmer(width: 0.65),
        ],
      ),
    );
  }

  Widget _summaryRowShimmer({required double width}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppShimmer.box(width: 100.w, height: 14.h, borderRadius: 4.r),
        AppShimmer.box(
          width: (120 * width).w.clamp(72.w, 140.w),
          height: 16.h,
          borderRadius: 4.r,
        ),
      ],
    );
  }
}

class _MyBorrowHistoryRowShimmer extends StatelessWidget {
  const _MyBorrowHistoryRowShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.projectFundsLedgerCardBg,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.projectFundsLedgerBorder),
      ),
      child: Row(
        children: [
          AppShimmer.box(width: 44.w, height: 44.w, borderRadius: 12.r),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppShimmer.box(width: 88.w, height: 15.h, borderRadius: 4.r),
                SizedBox(height: 4.h),
                AppShimmer.box(width: 104.w, height: 13.h, borderRadius: 4.r),
              ],
            ),
          ),
          AppShimmer.box(width: 72.w, height: 28.h, borderRadius: 100.r),
        ],
      ),
    );
  }
}
