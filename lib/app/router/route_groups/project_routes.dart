import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../features/borrow/presentation/cubit/borrow_cubit.dart';
import '../../../features/borrow/presentation/pages/borrow_flow_screen.dart';
import '../../../features/contribute/presentation/cubit/contribute_cubit.dart';
import '../../../features/contribute/presentation/pages/contribute_flow_screen.dart';
import '../../../features/project_detail/domain/entities/borrow_request_entity.dart';
import '../../../features/project_detail/domain/entities/member_entity.dart';
import '../../../features/project_detail/domain/entities/project_detail_route_args.dart';
import '../../../features/project_detail/presentation/pages/borrow_requests_screen.dart';
import '../../../features/project_detail/presentation/pages/cancel_project_screen.dart';
import '../../../features/project_detail/presentation/pages/create_announcement_screen.dart';
import '../../../features/project_detail/presentation/pages/investment_project_detail_screen.dart';
import '../../../features/project_detail/presentation/pages/join_requests_screen.dart';
import '../../../features/project_detail/presentation/pages/mark_project_successful_screen.dart';
import '../../../features/project_detail/presentation/pages/member_detail_screen.dart';
import '../../../features/project_detail/presentation/pages/member_penalty_action_screen.dart';
import '../../../features/project_detail/presentation/pages/project_cancelled_screen.dart';
import '../../../features/project_detail/presentation/pages/project_detail_screen.dart';
import '../../../features/project_detail/presentation/pages/user_status_flow_screen.dart';
import '../../../features/project_detail/presentation/pages/user_success_vote_screen.dart';
import '../app_routes.dart';
import '../route_args/project_detail_flow_args.dart';
import '../route_args/project_wallet_flow_args.dart';
import 'route_group_types.dart';

List<RouteBase> buildProjectRoutes({
  required InvalidRouteBuilder invalidRouteScreen,
}) {
  return [
    GoRoute(
      path: AppRoutes.projectDetail,
      builder: (context, state) {
        final extra = state.extra;
        if (extra is! ProjectDetailRouteArgs) return invalidRouteScreen();
        return ProjectDetailScreen(project: extra.project);
      },
    ),
    GoRoute(
      path: AppRoutes.investmentProjectDetail,
      builder: (context, state) {
        final extra = state.extra;
        if (extra is! ProjectDetailRouteArgs) return invalidRouteScreen();
        return InvestmentProjectDetailScreen(project: extra.project);
      },
    ),
    GoRoute(
      path: AppRoutes.contributeFlow,
      builder: (context, state) {
        final extra = state.extra;
        if (extra is! ProjectWalletFlowArgs) return invalidRouteScreen();
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
        if (extra is! ProjectWalletFlowArgs) return invalidRouteScreen();
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
        if (extra is! MemberDetailRouteArgs) return invalidRouteScreen();
        if (extra.member is! MemberEntity) return invalidRouteScreen();
        return MemberDetailScreen(
          member: extra.member as MemberEntity,
          projectName: extra.projectName,
          isLeaderView: extra.isLeaderView,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.memberPenaltyAction,
      builder: (context, state) {
        final extra = state.extra;
        if (extra is! MemberEntity) return invalidRouteScreen();
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
        if (extra is! BorrowRequestsRouteArgs) return invalidRouteScreen();
        final requests = extra.requests;
        if (!requests.every((e) => e is BorrowRequestEntity)) {
          return invalidRouteScreen();
        }
        return BorrowRequestsScreen(
          requests: requests.cast<BorrowRequestEntity>(),
          isLeaderMode: extra.isLeaderMode,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.markProjectSuccessful,
      builder: (context, state) {
        final extra = state.extra;
        if (extra is! MarkSuccessfulRouteArgs) return invalidRouteScreen();
        return MarkProjectSuccessfulScreen(memberCount: extra.memberCount);
      },
    ),
    GoRoute(
      path: AppRoutes.cancelProject,
      builder: (context, state) {
        final extra = state.extra;
        if (extra is! CancelProjectRouteArgs) return invalidRouteScreen();
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
        if (extra is! ProjectCancelledRouteArgs) return invalidRouteScreen();
        return ProjectCancelledScreen(projectName: extra.projectName);
      },
    ),
    GoRoute(
      path: AppRoutes.userStatusFlow,
      builder: (context, state) {
        final extra = state.extra;
        if (extra is! UserStatusFlowArgs) return invalidRouteScreen();
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
        if (extra is! UserSuccessVoteArgs) return invalidRouteScreen();
        return UserSuccessVoteScreen(args: extra);
      },
    ),
  ];
}

