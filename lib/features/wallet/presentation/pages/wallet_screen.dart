import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/failure_mapper.dart';
import '../../../../core/services/risk_disclaimer_gate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/app_error_view.dart';
import '../../../../core/widgets/common/app_shimmer.dart';
import '../../../../core/widgets/common/post_auth_gradient_background.dart';
import '../../../../core/widgets/common/post_auth_header.dart';
import '../../../../core/widgets/text/app_text.dart';
import '../../domain/wallet_transaction_type.dart';
import '../cubit/wallet_cubit.dart';
import '../cubit/wallet_state.dart';
import '../cubit/wallet_transaction_cubit.dart';
import '../widgets/wallet_action_buttons.dart';
import '../widgets/wallet_overview_card.dart';
import '../widgets/wallet_recent_activity_empty.dart';
import '../widgets/wallet_recent_activity_list.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cubit = context.read<WalletCubit>();
      if (cubit.state.wallet == null && !cubit.state.isLoading) {
        cubit.load();
      }
    });
  }

  Future<void> _openFlow(
    BuildContext context,
    WalletTransactionType type,
  ) async {
    final accepted = await RiskDisclaimerGate.ensureAccepted(context);
    if (!accepted || !context.mounted) return;
    context.read<WalletTransactionCubit>().reset();
    context
        .read<WalletTransactionCubit>()
        .setTransactionType(type);
    context.push(AppRoutes.transactionAmount);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletCubit, WalletState>(
      builder: (context, state) {
        return PostAuthGradientBackground(
          child: Column(
            children: [
              PostAuthHeader(
                title: AppStrings.walletTitle,
                titleStyle: GoogleFonts.lato(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral1200,
                ),
              ),
              if (state.isLoading && state.wallet == null)
                const Expanded(child: WalletTabShimmer())
              else if (state.hasLoadError)
                Expanded(
                  child: AppErrorView(
                    message: FailureMapper.userMessage(state.failure!),
                    onRetry: () => context.read<WalletCubit>().load(
                          forceRefresh: true,
                        ),
                  ),
                )
              else ...[
                WalletOverviewCard(
                  walletAmount: state.walletAmountFormatted,
                  borrowedAmount: state.borrowedAmountFormatted,
                  lockedInProjectsAmount: state.wallet != null
                      ? state.lockedInProjectsFormatted
                      : null,
                ),
                if (state.hasPendingWithdrawal)
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 4.h),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.grey100,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: AppText(
                              AppStrings.walletPendingWithdrawalLabel,
                              style: GoogleFonts.lato(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.neutral1200,
                              ),
                            ),
                          ),
                          AppText(
                            state.pendingWithdrawalFormatted,
                            style: GoogleFonts.lato(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.neutral1200,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                WalletActionButtons(
                  onDeposit: () =>
                      _openFlow(context, WalletTransactionType.deposit),
                  onWithdraw: () =>
                      _openFlow(context, WalletTransactionType.withdraw),
                ),
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
                          child: Row(
                            children: [
                              AppText(
                                AppStrings.recentActivityHeader,
                                style: GoogleFonts.lato(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.guidelineTitle,
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => context
                                    .push(AppRoutes.walletRecentActivity),
                                child: AppText(
                                  AppStrings.viewAllRequests,
                                  style: GoogleFonts.lato(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Expanded(
                          child: state.recentActivity.isEmpty
                              ? const WalletRecentActivityEmpty()
                              : WalletRecentActivityList(
                                  transactions: state.recentActivity,
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
