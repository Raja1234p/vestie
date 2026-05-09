import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:go_router/go_router.dart';



import '../../../features/auth/presentation/pages/agreement_screen.dart';

import '../../../features/auth/presentation/pages/forgot_password_screen.dart';

import '../../../features/auth/presentation/pages/login_screen.dart';

import '../../../features/auth/presentation/pages/register_screen.dart';

import '../../../features/auth/presentation/pages/reset_password_screen.dart';

import '../../../features/auth/presentation/pages/verify_screen.dart';

import 'package:vestie/leader/features/create_project/presentation/pages/create_project_amount_screen.dart';

import 'package:vestie/leader/features/create_project/presentation/pages/create_project_borrowing_settings_screen.dart';

import 'package:vestie/leader/features/create_project/presentation/pages/create_project_details_screen.dart';

import 'package:vestie/leader/features/create_project/presentation/pages/create_project_investment_settings_screen.dart';

import 'package:vestie/leader/features/create_project/presentation/pages/create_project_review_screen.dart';

import 'package:vestie/leader/features/create_project/presentation/pages/create_project_saving_settings_screen.dart';

import 'package:vestie/leader/features/create_project/presentation/pages/create_project_success_screen.dart';

import '../../../features/dashboard/presentation/pages/dashboard_screen.dart';

import '../../../features/notifications/presentation/cubit/notifications_cubit.dart';

import '../../../features/notifications/presentation/pages/notifications_screen.dart';

import '../../../features/onboarding/presentation/pages/onboarding_screen.dart';

import '../../../features/splash/presentation/pages/splash_screen.dart';

import '../app_routes.dart';



List<RouteBase> buildCoreRoutes() {

  return [

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

      builder: (context, state) {

        final email = state.extra is String ? state.extra as String : '';

        return VerifyScreen(email: email);

      },

    ),

    GoRoute(

      path: AppRoutes.forgotPassword,

      builder: (context, _) => const ForgotPasswordScreen(),

    ),

    GoRoute(

      path: AppRoutes.resetPassword,

      builder: (context, state) {

        final email = state.extra is String ? state.extra as String : '';

        return ResetPasswordScreen(email: email);

      },

    ),

    GoRoute(

      path: AppRoutes.agreement,

      builder: (context, _) => const AgreementScreen(),

    ),

    GoRoute(

      path: AppRoutes.dashboard,

      builder: (context, _) => const DashboardScreen(),

    ),

    GoRoute(

      path: AppRoutes.notifications,

      builder: (context, _) => BlocProvider(

        create: (_) => NotificationsCubit(),

        child: const NotificationsScreen(),

      ),

    ),

    GoRoute(

      path: AppRoutes.createProjectAmount,

      builder: (context, _) => const CreateProjectAmountScreen(),

    ),

    GoRoute(

      path: AppRoutes.createProjectDetails,

      builder: (context, state) => CreateProjectDetailsScreen(

        isEditMode: state.extra == true,

      ),

    ),

    GoRoute(

      path: AppRoutes.createProjectSavingSettings,

      builder: (context, state) => CreateProjectSavingSettingsScreen(

        isEditMode: state.extra == true,

      ),

    ),

    GoRoute(

      path: AppRoutes.createProjectFundsBorrowing,

      builder: (context, state) => CreateProjectBorrowingSettingsScreen(

        isEditMode: state.extra == true,

      ),

    ),

    GoRoute(

      path: AppRoutes.createProjectInvestmentSettings,

      builder: (context, state) => CreateProjectInvestmentSettingsScreen(

        isEditMode: state.extra == true,

      ),

    ),

    GoRoute(

      path: AppRoutes.createProjectReview,

      builder: (context, _) => const CreateProjectReviewScreen(),

    ),

    GoRoute(

      path: AppRoutes.createProjectSuccess,

      builder: (context, _) => const CreateProjectSuccessScreen(),

    ),

  ];

}

