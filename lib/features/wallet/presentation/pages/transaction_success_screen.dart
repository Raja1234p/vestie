import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/app_routes.dart';
import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/widgets/common/app_success_screen.dart';
import '../../domain/wallet_transaction_type.dart';
import '../cubit/wallet_transaction_cubit.dart';

class TransactionSuccessScreen extends StatelessWidget {
  const TransactionSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletTransactionCubit, WalletTransactionState>(
      builder: (context, state) {
        final isDeposit = state.transactionType == WalletTransactionType.deposit;
        
        return AppSuccessScreen(
          // Assuming we have a general success image. If not, projectCreatedImage works for now or we add a new one later.
          svgAssetPath: AppAssets.projectCreatedImage, 
          title: isDeposit ? AppStrings.depositSuccessTitle : AppStrings.withdrawSuccessTitle,
          buttonText: AppStrings.btnBackToWallet,
          onButtonPressed: () {
            context.read<WalletTransactionCubit>().reset();
            // Popping back to dashboard. If there's a dedicated Wallet tab, we'd navigate there.
            context.go(AppRoutes.dashboard);
          },
        );
      },
    );
  }
}
