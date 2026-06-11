import 'package:flutter/material.dart';

import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_shimmer_base.dart';

import '../models/my_borrow_content_kind.dart';

/// My Borrow screen skeleton — layout matches the loaded UI for each state.
class MyBorrowScreenShimmer extends StatelessWidget {
  const MyBorrowScreenShimmer({super.key, required this.kind});

  final MyBorrowContentKind kind;

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: AppDimens.postAuthFlowScrollPadding,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: switch (kind) {
                MyBorrowContentKind.approved =>
                  const _MyBorrowApprovedShimmerBody(),
                MyBorrowContentKind.pending =>
                  const _MyBorrowPendingShimmerBody(),
                MyBorrowContentKind.historyOnly =>
                  const _MyBorrowHistoryShimmerBody(),
                MyBorrowContentKind.empty => const Align(
                  alignment: Alignment.center,
                  child: _MyBorrowEmptyShimmerBody(),
                ),
              },
            ),
          );
        },
      ),
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
        AppShimmer.box(width: 120, height: 18, borderRadius: 4),
        const SizedBox(height: 8),
        AppShimmer.box(width: 180, height: 40, borderRadius: 6),
        const SizedBox(height: 24),
        AppShimmer.box(width: 100, height: 16, borderRadius: 4),
        const SizedBox(height: 10),
        AppShimmer.box(width: double.infinity, height: 168, borderRadius: 14),
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
        AppShimmer.box(width: 120, height: 18, borderRadius: 4),
        const SizedBox(height: 10),
        AppShimmer.box(width: 160, height: 32, borderRadius: 6),
        const SizedBox(height: 20),
        AppShimmer.box(width: 130, height: 18, borderRadius: 4),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: AppShimmer.box(
                width: double.infinity,
                height: 52,
                borderRadius: 14,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AppShimmer.box(
                width: double.infinity,
                height: 52,
                borderRadius: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AppShimmer.box(width: double.infinity, height: 44, borderRadius: 12),
        const SizedBox(height: 20),
        AppShimmer.box(width: 120, height: 18, borderRadius: 4),
        const SizedBox(height: 10),
        const _MyBorrowHistoryRowShimmer(),
        const SizedBox(height: 10),
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
        AppShimmer.box(width: 120, height: 18, borderRadius: 4),
        const SizedBox(height: 10),
        const _MyBorrowHistoryRowShimmer(),
        const SizedBox(height: 10),
        const _MyBorrowHistoryRowShimmer(),
        const SizedBox(height: 10),
        const _MyBorrowHistoryRowShimmer(),
      ],
    );
  }
}

class _MyBorrowEmptyShimmerBody extends StatelessWidget {
  const _MyBorrowEmptyShimmerBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppShimmer.box(width: 100, height: 100, borderRadius: 50),
        const SizedBox(height: 20),
        AppShimmer.box(width: 200, height: 22, borderRadius: 4),
        const SizedBox(height: 8),
        AppShimmer.box(width: 260, height: 18, borderRadius: 4),
      ],
    );
  }
}

class _MyBorrowHistoryRowShimmer extends StatelessWidget {
  const _MyBorrowHistoryRowShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          AppShimmer.box(width: 36, height: 36, borderRadius: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppShimmer.box(width: 80, height: 15, borderRadius: 4),
                const SizedBox(height: 4),
                AppShimmer.box(width: 100, height: 13, borderRadius: 4),
              ],
            ),
          ),
          AppShimmer.box(width: 72, height: 24, borderRadius: 100),
        ],
      ),
    );
  }
}
