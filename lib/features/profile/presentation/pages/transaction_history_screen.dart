import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/app_loader.dart';
import '../../domain/entities/transaction.dart';
import '../cubit/transaction_history_cubit.dart';
import '../widgets/profile_sub_header.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TransactionHistoryCubit(),
      child: const _TxBody(),
    );
  }
}

class _TxBody extends StatelessWidget {
  const _TxBody();

  static const _filters = [
    AppStrings.filterAllTx,
    AppStrings.filterDeposits,
    AppStrings.filterWithdrawals,
    AppStrings.filterContributions,
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionHistoryCubit, TransactionHistoryState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.dashBg,
          body: Column(
            children: [
              ProfileSubHeader(title: AppStrings.transactionHistoryTitle),
              // ── Filter chips ──────────────────────────────
              Container(
                color: Colors.white,
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filters.map((f) {
                      final active = f == state.activeFilter;
                      return GestureDetector(
                        onTap: () => context
                            .read<TransactionHistoryCubit>()
                            .selectFilter(f),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: EdgeInsets.only(right: 8.w),
                          padding: EdgeInsets.symmetric(
                              horizontal: 14.w, vertical: 7.h),
                          decoration: BoxDecoration(
                            color: active
                                ? AppColors.chipActiveBg
                                : AppColors.chipInactiveBg,
                            borderRadius: BorderRadius.circular(100.r),
                            border: Border.all(
                              color: active
                                  ? AppColors.chipActiveBg
                                  : AppColors.chipBorder,
                            ),
                          ),
                          child: Text(f,
                              style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: active
                                      ? AppColors.chipActiveText
                                      : AppColors.chipInactiveText)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              // ── List ─────────────────────────────────────
              Expanded(
                child: state.loading
                    ? const AppLoader()
                    : ListView.separated(
                        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                        itemCount: state.filtered.length,
                        separatorBuilder: (context, _) => SizedBox(height: 10.h),
                        itemBuilder: (_, i) =>
                            _TxItem(tx: state.filtered[i]),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TxItem extends StatelessWidget {
  final Transaction tx;
  const _TxItem({required this.tx});

  Color get _iconBg {
    switch (tx.type) {
      case TransactionType.deposit:      return AppColors.txDepositBg;
      case TransactionType.contribution: return AppColors.txContribBg;
      default:                            return AppColors.txBorrowBg;
    }
  }

  Color get _iconColor {
    switch (tx.type) {
      case TransactionType.deposit:      return AppColors.txDepositIcon;
      case TransactionType.contribution: return AppColors.txContribIcon;
      default:                            return AppColors.txBorrowIcon;
    }
  }

  String get _svgIcon {
    switch (tx.type) {
      case TransactionType.deposit:      return AppAssets.iconDeposit;
      case TransactionType.contribution: return AppAssets.iconContribution;
      default:                            return AppAssets.iconDollarCircle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40.w, height: 40.w,
            decoration: BoxDecoration(
              color: _iconBg,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SvgPicture.asset(
                _svgIcon,
                width: 20.w,
                height: 20.w,
                colorFilter: ColorFilter.mode(_iconColor, BlendMode.srcIn),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                SizedBox(height: 2.h),
                Text(tx.date,
                    style: GoogleFonts.inter(
                        fontSize: 11.sp, color: AppColors.textBody)),
              ],
            ),
          ),
          Text(
            tx.formattedAmount,
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: tx.isPositive ? AppColors.txPositive : AppColors.txNegative,
            ),
          ),
        ],
      ),
    );
  }
}
