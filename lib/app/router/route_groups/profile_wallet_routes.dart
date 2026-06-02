import 'package:go_router/go_router.dart';

import '../../../features/profile/presentation/pages/edit_profile_screen.dart';
import '../../../features/profile/presentation/pages/key_guidelines_screen.dart';
import '../../../features/profile/domain/entities/payment_method_picker_behavior.dart';
import '../../../features/profile/presentation/pages/payment_methods_screen.dart';
import '../../../features/profile/presentation/pages/transaction_history_screen.dart';
import '../../../features/wallet/presentation/pages/transaction_amount_screen.dart';
import '../../../features/wallet/presentation/pages/transaction_confirmation_screen.dart';
import '../../../features/wallet/presentation/pages/wallet_recent_activity_screen.dart';
import '../../../features/wallet/presentation/pages/transaction_success_screen.dart';
import '../../../features/wallet/presentation/pages/withdraw_method_screen.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/features/wallet/presentation/cubit/wallet_deposit_cubit.dart';
import 'package:vestie/features/wallet/presentation/cubit/wallet_withdraw_cubit.dart';
import 'package:vestie/features/bank_accounts/presentation/pages/bank_link_onboarding_screen.dart';
import 'package:vestie/features/kyc/presentation/pages/kyc_onboarding_screen.dart';
import 'package:vestie/features/wallet/presentation/pages/select_bank_account_screen.dart';
import 'package:vestie/features/profile/presentation/pages/completed_projects_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../app_routes.dart';

List<RouteBase> buildProfileWalletRoutes() {
  return [
    GoRoute(
      path: AppRoutes.editProfile,
      builder: (context, _) => const EditProfileScreen(),
    ),
    GoRoute(
      path: AppRoutes.paymentMethods,
      builder: (context, _) => const PaymentMethodsScreen(),
    ),
    GoRoute(
      path: AppRoutes.transactionHistory,
      builder: (context, _) => const TransactionHistoryScreen(),
    ),
    GoRoute(
      path: AppRoutes.completedProjects,
      builder: (context, _) => const CompletedProjectsScreen(),
    ),
    GoRoute(
      path: AppRoutes.keyGuidelines,
      builder: (context, _) => const KeyGuidelinesScreen(),
    ),
    GoRoute(
      path: AppRoutes.transactionAmount,
      builder: (context, _) => const TransactionAmountScreen(),
    ),
    GoRoute(
      path: AppRoutes.withdrawMethod,
      builder: (context, _) => const WithdrawMethodScreen(),
    ),
    GoRoute(
      path: AppRoutes.walletRecentActivity,
      builder: (context, _) => const WalletRecentActivityScreen(),
    ),
    GoRoute(
      path: AppRoutes.selectPaymentMethod,
      builder: (context, state) {
        final behavior = state.extra is PaymentMethodPickerBehavior
            ? state.extra! as PaymentMethodPickerBehavior
            : PaymentMethodPickerBehavior.depositFlow;
        return PaymentMethodsScreen(
          isSelectionMode: true,
          pickerBehavior: behavior,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.selectBankAccount,
      builder: (context, _) => const SelectBankAccountScreen(),
    ),
    GoRoute(
      path: AppRoutes.kycOnboarding,
      builder: (context, _) => const KycOnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.bankLinkOnboarding,
      builder: (context, _) => const BankLinkOnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.transactionConfirmation,
      builder: (context, _) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => WalletDepositCubit(
              runWalletDepositUseCase:
                  ServiceLocator.instance.runWalletDepositUseCase,
            ),
          ),
          BlocProvider(
            create: (_) => WalletWithdrawCubit(
              previewWithdrawalUseCase:
                  ServiceLocator.instance.previewWithdrawalUseCase,
              runWalletWithdrawUseCase:
                  ServiceLocator.instance.runWalletWithdrawUseCase,
            ),
          ),
        ],
        child: const TransactionConfirmationScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.transactionSuccess,
      builder: (context, _) => const TransactionSuccessScreen(),
    ),
  ];
}

