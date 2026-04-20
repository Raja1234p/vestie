import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/post_auth_gradient_background.dart';
import '../../../../core/widgets/text/app_text.dart';
import '../cubit/wallet_transaction_cubit.dart';
import '../../domain/wallet_transaction_type.dart';
import '../widgets/wallet_overview_card.dart';
import '../widgets/wallet_action_buttons.dart';
import '../../../../core/widgets/common/app_transaction_item.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PostAuthGradientBackground(
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────────────
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
              child: Row(
                children: [
                  AppText(
                    AppStrings.walletTitle,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.grey1100,
                          letterSpacing: -0.5,
                        ),
                  ),
                ],
              ),
            ),
          ),

          // ── Wallet Overview ─────────────────────────────────────
          const WalletOverviewCard(
            walletAmount: '\$2,300',
            borrowedAmount: '\$1,200',
          ),

          // ── Actions ──────────────────────────────────────────────
          WalletActionButtons(
            onDeposit: () {
              context.read<WalletTransactionCubit>().reset();
              context.read<WalletTransactionCubit>().setTransactionType(WalletTransactionType.deposit);
              context.push(AppRoutes.transactionAmount);
            },
            onWithdraw: () {
              context.read<WalletTransactionCubit>().reset();
              context.read<WalletTransactionCubit>().setTransactionType(WalletTransactionType.withdraw);
              context.push(AppRoutes.transactionAmount);
            },
          ),

          // ── Recent Activity Section ─────────────────────────────
          Expanded(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: AppText(
                      AppStrings.recentActivityHeader,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.only(bottom: 24.h, top: 4.h),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        AppTransactionItem(
                          type: AppTransactionType.deposit,
                          title: AppStrings.txWalletDeposit,
                          date: 'Mar 12',
                          amount: '500',
                          isNegative: false,
                        ),
                        AppTransactionItem(
                          type: AppTransactionType.contribution,
                          title: '${AppStrings.txContributionPrefix}Family Vacation',
                          date: 'Mar 11',
                          amount: '115',
                          isNegative: true,
                        ),
                        AppTransactionItem(
                          type: AppTransactionType.borrow,
                          title: '${AppStrings.txBorrowPrefix}Family Vacation',
                          date: 'Mar 12',
                          amount: '650',
                          isNegative: false,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
