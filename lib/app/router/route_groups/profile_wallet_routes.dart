import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../features/profile/presentation/cubit/profile_cubit.dart';
import '../../../features/profile/presentation/pages/add_card_screen.dart';
import '../../../features/profile/presentation/pages/edit_profile_screen.dart';
import '../../../features/profile/presentation/pages/key_guidelines_screen.dart';
import '../../../features/profile/presentation/pages/payment_methods_screen.dart';
import '../../../features/profile/presentation/pages/transaction_history_screen.dart';
import '../../../features/wallet/presentation/pages/transaction_amount_screen.dart';
import '../../../features/wallet/presentation/pages/transaction_confirmation_screen.dart';
import '../../../features/wallet/presentation/pages/transaction_success_screen.dart';
import '../app_routes.dart';

List<RouteBase> buildProfileWalletRoutes() {
  return [
    GoRoute(
      path: AppRoutes.editProfile,
      builder: (context, _) => BlocProvider(
        create: (_) => ProfileCubit(),
        child: const EditProfileScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.paymentMethods,
      builder: (context, _) => const PaymentMethodsScreen(),
    ),
    GoRoute(
      path: AppRoutes.addCard,
      builder: (context, _) => const AddCardScreen(),
    ),
    GoRoute(
      path: AppRoutes.transactionHistory,
      builder: (context, _) => const TransactionHistoryScreen(),
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
      path: AppRoutes.selectPaymentMethod,
      builder: (context, _) => const PaymentMethodsScreen(isSelectionMode: true),
    ),
    GoRoute(
      path: AppRoutes.transactionConfirmation,
      builder: (context, _) => const TransactionConfirmationScreen(),
    ),
    GoRoute(
      path: AppRoutes.transactionSuccess,
      builder: (context, _) => const TransactionSuccessScreen(),
    ),
  ];
}

