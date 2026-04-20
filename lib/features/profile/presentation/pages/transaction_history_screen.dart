import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/app_loader.dart';
import '../../../../core/widgets/common/post_auth_gradient_background.dart';
import '../cubit/transaction_history_cubit.dart';
import '../widgets/profile_sub_header.dart';
import 'tx_filter_bar.dart';
import '../../../../core/widgets/common/app_transaction_item.dart';
import '../../domain/entities/transaction.dart';

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

  AppTransactionType _mapType(TransactionType type) {
    switch (type) {
      case TransactionType.deposit:
        return AppTransactionType.deposit;
      case TransactionType.contribution:
        return AppTransactionType.contribution;
      case TransactionType.withdrawal:
        return AppTransactionType.withdrawal;
      case TransactionType.lend:
        return AppTransactionType.lend;
      default:
        return AppTransactionType.borrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionHistoryCubit, TransactionHistoryState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: PostAuthGradientBackground(
            child: Column(
              children: [
                ProfileSubHeader(title: AppStrings.transactionHistoryTitle),
                TxFilterBar(activeFilter: state.activeFilter),
                Expanded(
                  child: state.loading
                      ? const AppLoader()
                      : ListView.separated(
                          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                          itemCount: state.filtered.length,
                          separatorBuilder: (context, _) => SizedBox(height: 10.h),
                          itemBuilder: (_, i) {
                            final tx = state.filtered[i];
                            return AppTransactionItem(
                              type: _mapType(tx.type),
                              title: tx.title,
                              date: tx.date,
                              amount: tx.amount.abs().toStringAsFixed(0),
                              isNegative: !tx.isPositive,
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
