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
import '../../features/profile/presentation/pages/key_guidelines_screen.dart';
import '../../features/profile/presentation/pages/payment_methods_screen.dart';
import '../../features/profile/presentation/pages/transaction_history_screen.dart';
import '../../features/contribute/presentation/cubit/contribute_cubit.dart';
import '../../features/contribute/presentation/pages/contribute_flow_screen.dart';
import '../../features/borrow/presentation/cubit/borrow_cubit.dart';
import '../../features/borrow/presentation/pages/borrow_flow_screen.dart';
import '../../features/notifications/presentation/cubit/notifications_cubit.dart';
import '../../features/notifications/presentation/pages/notifications_screen.dart';
import '../../features/splash/presentation/pages/splash_screen.dart';
import '../../features/wallet/presentation/pages/transaction_amount_screen.dart';
import '../../features/wallet/presentation/pages/transaction_confirmation_screen.dart';
import '../../features/wallet/presentation/pages/transaction_success_screen.dart';
import '../../features/project_detail/domain/entities/project_detail_route_args.dart';
import '../../features/project_detail/domain/entities/member_entity.dart';
import '../../features/project_detail/presentation/pages/project_detail_screen.dart';
import '../../features/project_detail/presentation/pages/borrow_requests_screen.dart';
import '../../features/project_detail/presentation/pages/investment_project_detail_screen.dart';
import '../../features/project_detail/presentation/pages/member_detail_screen.dart';
import '../../features/project_detail/presentation/pages/member_penalty_action_screen.dart';
import '../../features/project_detail/presentation/pages/create_announcement_screen.dart';
import '../../features/project_detail/presentation/pages/join_requests_screen.dart';
import '../../features/project_detail/presentation/pages/cancel_project_screen.dart';
import '../../features/project_detail/presentation/pages/mark_project_successful_screen.dart';
import '../../features/project_detail/presentation/pages/project_cancelled_screen.dart';
import '../../features/project_detail/presentation/pages/user_status_flow_screen.dart';
import '../../features/project_detail/presentation/pages/user_success_vote_screen.dart';
import 'app_routes.dart';

class AppRouter {
  static Widget _invalidRouteScreen() => const Scaffold(
        body: Center(child: Text(AppStrings.routeNotFound)),
      );

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.dashboard,
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
        builder: (context, _) => const KeyGuidelinesScreen(),
      ),

      // ── Wallet Transaction ──────────────────────────────────────────────
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

      // ── Project Detail ────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.projectDetail,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is! ProjectDetailRouteArgs) return _invalidRouteScreen();
          return ProjectDetailScreen(project: extra.project);
        },
      ),
      GoRoute(
        path: AppRoutes.investmentProjectDetail,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is! ProjectDetailRouteArgs) return _invalidRouteScreen();
          return InvestmentProjectDetailScreen(project: extra.project);
        },
      ),
      GoRoute(
        path: AppRoutes.contributeFlow,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is! ProjectWalletFlowArgs) return _invalidRouteScreen();
          return BlocProvider(
            create: (_) => ContributeCubit(extra),
            child: const ContributeFlowScreen(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.borrowFlow,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is! ProjectWalletFlowArgs) return _invalidRouteScreen();
          return BlocProvider(
            create: (_) => BorrowCubit(extra),
            child: const BorrowFlowScreen(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.memberDetail,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is! MemberDetailRouteArgs) return _invalidRouteScreen();
          return MemberDetailScreen(
            member: extra.member,
            projectName: extra.projectName,
            isLeaderView: extra.isLeaderView,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.memberPenaltyAction,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is! MemberEntity) return _invalidRouteScreen();
          return MemberPenaltyActionScreen(member: extra);
        },
      ),
      GoRoute(
        path: AppRoutes.createAnnouncement,
        builder: (context, _) => const CreateAnnouncementScreen(),
      ),
      GoRoute(
        path: AppRoutes.joinRequests,
        builder: (context, _) => const JoinRequestsScreen(),
      ),
      GoRoute(
        path: AppRoutes.borrowRequests,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is! BorrowRequestsRouteArgs) return _invalidRouteScreen();
          return BorrowRequestsScreen(
            requests: extra.requests,
            isLeaderMode: extra.isLeaderMode,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.markProjectSuccessful,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is! MarkSuccessfulRouteArgs) {
            return _invalidRouteScreen();
          }
          return MarkProjectSuccessfulScreen(
            memberCount: extra.memberCount,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.cancelProject,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is! CancelProjectRouteArgs) {
            return _invalidRouteScreen();
          }
          return CancelProjectScreen(
            projectName: extra.projectName,
            membersWithUnpaidBorrows: extra.membersWithUnpaidBorrows,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.projectCancelled,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is! ProjectCancelledRouteArgs) {
            return _invalidRouteScreen();
          }
          return ProjectCancelledScreen(
            projectName: extra.projectName,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.userStatusFlow,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is! UserStatusFlowArgs) {
            return _invalidRouteScreen();
          }
          return UserStatusFlowScreen(
            projectName: extra.projectName,
            kind: extra.kind,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.userSuccessVote,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is! UserSuccessVoteArgs) {
            return _invalidRouteScreen();
          }
          return UserSuccessVoteScreen(args: extra);
        },
      ),
    ],
    errorBuilder: (context, _) => const Scaffold(
      body: Center(child: Text(AppStrings.routeNotFound)),
    ),
  );
}
