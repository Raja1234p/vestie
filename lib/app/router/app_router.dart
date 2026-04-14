import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';

import '../../features/auth/presentation/pages/agreement_screen.dart';
import '../../features/auth/presentation/pages/forgot_password_screen.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/auth/presentation/pages/register_screen.dart';
import '../../features/auth/presentation/pages/reset_password_screen.dart';
import '../../features/auth/presentation/pages/verify_screen.dart';
import '../../features/create_project/presentation/pages/project_amount_screen.dart';
import '../../features/create_project/presentation/pages/project_borrowing_screen.dart';
import '../../features/create_project/presentation/pages/project_details_screen.dart';
import '../../features/create_project/presentation/pages/project_review_screen.dart';
import '../../features/create_project/presentation/pages/project_success_screen.dart';
import '../../features/dashboard/presentation/pages/dashboard_screen.dart';
import '../../features/onboarding/presentation/pages/onboarding_screen.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import '../../features/profile/presentation/pages/add_card_screen.dart';
import '../../features/profile/presentation/pages/edit_profile_screen.dart';
import '../../features/profile/presentation/pages/payment_methods_screen.dart';
import '../../features/profile/presentation/pages/transaction_history_screen.dart';
import '../../features/splash/presentation/pages/splash_screen.dart';
import 'app_routes.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, _) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, _) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, _) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, _) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.verify,
        builder: (context, state) =>
            VerifyScreen(email: state.extra as String? ?? ''),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, _) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (context, _) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.agreement,
        builder: (context, _) => const AgreementScreen(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, _) => const DashboardScreen(),
      ),

      // ── Create Project wizard ────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.createProjectAmount,
        builder: (context, _) => const ProjectAmountScreen(),
      ),
      GoRoute(
        path: AppRoutes.createProjectDetails,
        builder: (context, state) => ProjectDetailsScreen(
          isEditMode: state.extra == true,
        ),
      ),
      GoRoute(
        path: AppRoutes.createProjectBorrowing,
        builder: (context, state) => ProjectBorrowingScreen(
          isEditMode: state.extra == true,
        ),
      ),
      GoRoute(
        path: AppRoutes.createProjectReview,
        builder: (context, _) => const ProjectReviewScreen(),
      ),
      GoRoute(
        path: AppRoutes.createProjectSuccess,
        builder: (context, _) => const ProjectSuccessScreen(),
      ),

      // ── Profile sub-routes ──────────────────────────────────────────────
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
        builder: (context, _) => const Scaffold(
          body: Center(child: Text(AppStrings.keyGuidelinesComingSoon)),
        ),
      ),
    ],
    errorBuilder: (context, _) => const Scaffold(
      body: Center(child: Text(AppStrings.routeNotFound)),
    ),
  );
}
