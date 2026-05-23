import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/post_auth_gradient_background.dart';
import '../../../../core/widgets/common/post_auth_header.dart';
import '../../../../core/widgets/text/app_text.dart';
import '../cubit/wallet_transaction_cubit.dart';
import '../../domain/wallet_transaction_type.dart';
import '../widgets/wallet_overview_card.dart';
import '../widgets/wallet_action_buttons.dart';
import '../widgets/wallet_recent_activity_empty.dart';
import '../widgets/wallet_recent_activity_list.dart';
import '../../../profile/domain/mock_profile_data.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Replace with API-backed history when available.
    final transactions = MockProfileData.transactions;

    return PostAuthGradientBackground(
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────────────
          PostAuthHeader(
            title: AppStrings.walletTitle,
            titleStyle: GoogleFonts.lato(
              fontSize: 28.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral1200,
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
                    child: AppText(
                      AppStrings.recentActivityHeader,
                      style: GoogleFonts.lato(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.guidelineTitle,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Expanded(
                    child: transactions.isEmpty
                        ? const WalletRecentActivityEmpty()
                        : WalletRecentActivityList(
                            transactions: transactions,
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
