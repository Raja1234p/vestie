import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:go_router/go_router.dart';



import '../../../features/auth/presentation/pages/agreement_screen.dart';

import '../../../features/auth/presentation/pages/forgot_password_screen.dart';

import '../../../features/auth/presentation/pages/login_screen.dart';

import '../../../features/auth/presentation/pages/register_screen.dart';

import '../../../features/auth/presentation/pages/password_updated_success_screen.dart';

import '../../../features/auth/presentation/pages/reset_password_screen.dart';

import '../../../features/auth/presentation/pages/verify_screen.dart';

import '../../../features/auth/presentation/models/auth_route_extras.dart';

import 'package:vestie/leader/features/create_project/presentation/create_project_entry_mode.dart';

import 'package:vestie/leader/features/create_project/presentation/pages/create_project_amount_screen.dart';

import 'package:vestie/leader/features/create_project/presentation/pages/create_project_borrowing_settings_screen.dart';

import 'package:vestie/leader/features/create_project/presentation/pages/create_project_details_screen.dart';

import 'package:vestie/leader/features/create_project/presentation/pages/create_project_investment_settings_screen.dart';

import 'package:vestie/leader/features/create_project/presentation/pages/create_project_review_screen.dart';

import 'package:vestie/leader/features/create_project/presentation/pages/create_project_saving_settings_screen.dart';

import 'package:vestie/app/router/route_args/create_project_success_route_args.dart';
import 'package:vestie/leader/features/create_project/presentation/pages/create_project_success_screen.dart';

import '../../../features/dashboard/presentation/models/dashboard_shell_args.dart';
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

        final extra = state.extra;

        if (extra is VerifyScreenExtra) {

          return VerifyScreen(email: extra.email, flow: extra.flow);

        }

        if (extra is String) {

          return VerifyScreen(email: extra);

        }

        return const VerifyScreen(email: '');

      },

    ),

    GoRoute(

      path: AppRoutes.forgotPassword,

      builder: (context, _) => const ForgotPasswordScreen(),

    ),

    GoRoute(

      path: AppRoutes.resetPassword,

      builder: (context, state) {

        final extra = state.extra;

        if (extra is ResetPasswordExtra) {

          return ResetPasswordScreen(email: extra.email, code: extra.code);

        }

        return const ResetPasswordScreen(email: '', code: '');

      },

    ),

    GoRoute(

      path: AppRoutes.passwordUpdatedSuccess,

      builder: (context, _) => const PasswordUpdatedSuccessScreen(),

    ),

    GoRoute(

      path: AppRoutes.agreement,

      builder: (context, _) => const AgreementScreen(),

    ),

    GoRoute(

      path: AppRoutes.dashboard,

      builder: (context, state) {
        final extra = state.extra;
        final args = extra is DashboardShellArgs
            ? extra
            : const DashboardShellArgs();
        return DashboardScreen(shellArgs: args);
      },

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

        entryMode: createProjectEntryModeFromExtra(state.extra),

      ),

    ),

    GoRoute(

      path: AppRoutes.createProjectSavingSettings,

      builder: (context, state) => CreateProjectSavingSettingsScreen(

        entryMode: createProjectEntryModeFromExtra(state.extra),

      ),

    ),

    GoRoute(

      path: AppRoutes.createProjectFundsBorrowing,

      builder: (context, state) => CreateProjectBorrowingSettingsScreen(

        entryMode: createProjectEntryModeFromExtra(state.extra),

      ),

    ),

    GoRoute(

      path: AppRoutes.createProjectInvestmentSettings,

      builder: (context, state) => CreateProjectInvestmentSettingsScreen(

        entryMode: createProjectEntryModeFromExtra(state.extra),

      ),

    ),

    GoRoute(

      path: AppRoutes.createProjectReview,

      builder: (context, _) => const CreateProjectReviewScreen(),

    ),

    GoRoute(

      path: AppRoutes.createProjectSuccess,

      builder: (context, state) {
        final extra = state.extra;
        if (extra is CreateProjectSuccessRouteArgs) {
          return CreateProjectSuccessScreen(
            projectId: extra.projectId,
            projectName: extra.projectName,
            isInvestment: extra.isInvestment,
          );
        }
        final projectId = extra is String ? extra : '';
        return CreateProjectSuccessScreen(projectId: projectId);
      },

    ),

  ];

}

