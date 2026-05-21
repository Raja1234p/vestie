import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/features/project_detail/domain/entities/borrow_request_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/member_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_route_args.dart';
import 'package:vestie/features/project_detail/presentation/pages/member_detail_screen.dart';
import 'package:vestie/features/project_detail/presentation/pages/project_detail_screen.dart';
import 'package:vestie/features/project_detail/presentation/pages/project_funds_history_screen.dart';
import 'package:vestie/features/project_detail/presentation/models/investment_returns_ui_data.dart';
import 'package:vestie/features/project_detail/presentation/pages/group_members_screen.dart';
import 'package:vestie/leader/features/project_detail/presentation/pages/borrow_requests_screen.dart';
import 'package:vestie/leader/features/project_detail/presentation/pages/cancel_project_screen.dart';
import 'package:vestie/leader/features/project_detail/presentation/pages/leader_project_settings_screen.dart';
import 'package:vestie/leader/features/project_detail/presentation/pages/create_announcement_screen.dart';
import 'package:vestie/leader/features/project_detail/presentation/pages/join_requests_screen.dart';
import 'package:vestie/leader/features/project_detail/presentation/pages/leader_vote_started_screen.dart';
import 'package:vestie/leader/features/project_detail/presentation/pages/mark_project_successful_screen.dart';
import 'package:vestie/leader/features/project_detail/presentation/pages/stop_contributions_screen.dart';
import 'package:vestie/leader/features/project_detail/presentation/pages/voting_window_screen.dart';
import 'package:vestie/leader/features/project_detail/presentation/pages/member_penalty_action_screen.dart';
import 'package:vestie/user/features/borrow/presentation/cubit/borrow_cubit.dart';
import 'package:vestie/user/features/borrow/presentation/pages/borrow_flow_screen.dart';
import 'package:vestie/user/features/borrow/presentation/pages/my_borrow_request_screen.dart';
import 'package:vestie/user/features/contribute/presentation/pages/contribute_flow_screen.dart';
import 'package:vestie/user/features/contributions/presentation/bloc/contribute_event.dart';
import 'package:vestie/user/features/project_detail/presentation/pages/investment_project_detail_screen.dart';
import 'package:vestie/user/features/investment/presentation/models/user_investment_ui_snapshot.dart';
import 'package:vestie/features/project_detail/presentation/pages/investment_distribution_screen.dart';
import 'package:vestie/features/project_detail/presentation/pages/investment_funds_distributed_success_screen.dart';
import 'package:vestie/features/project_detail/presentation/pages/leader_distribute_funds_screen.dart';
import 'package:vestie/user/features/investment/presentation/pages/user_investment_returns_screen.dart';
import 'package:vestie/features/project_detail/presentation/pages/leave_project_warning_screen.dart';
import 'package:vestie/user/features/investment/presentation/pages/user_project_detail_screen.dart';
import 'package:vestie/user/features/investment/presentation/pages/user_project_funds_history_screen.dart';
import 'package:vestie/user/features/project_detail/presentation/pages/project_cancelled_screen.dart';
import 'package:vestie/user/features/project_detail/presentation/pages/user_status_flow_screen.dart';
import 'package:vestie/user/features/project_detail/presentation/pages/member_vote_outcome_screen.dart';
import 'package:vestie/user/features/project_detail/presentation/pages/user_success_vote_screen.dart';
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
        return ProjectDetailScreen(
          projectId: extra.projectId,
          initialProjectName: extra.initialProjectName,
          refreshHomeOnPop: extra.refreshHomeOnPop,
          refreshDiscoverOnPop: extra.refreshDiscoverOnPop,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.investmentProjectDetail,
      builder: (context, state) {
        final extra = state.extra;
        if (extra is! ProjectDetailRouteArgs) return invalidRouteScreen();
        return InvestmentProjectDetailScreen(
          projectId: extra.projectId,
          initialProjectName: extra.initialProjectName,
          refreshHomeOnPop: extra.refreshHomeOnPop,
          refreshDiscoverOnPop: extra.refreshDiscoverOnPop,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.contributeFlow,
      builder: (context, state) {
        final extra = state.extra;
        if (extra is! ProjectWalletFlowArgs) return invalidRouteScreen();
        return BlocProvider(
          create: (_) => ServiceLocator.instance.createContributeBloc()
            ..add(InitArgsEvent(args: extra)),
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
          projectId: extra.projectId,
          projectName: extra.projectName,
          project: extra.project,
          isLeaderView: extra.isLeaderView,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.memberPenaltyAction,
      builder: (context, state) {
        final extra = state.extra;
        if (extra is! MemberPenaltyActionRouteArgs) return invalidRouteScreen();
        if (extra.member is! MemberEntity) return invalidRouteScreen();
        return MemberPenaltyActionScreen(
          member: extra.member as MemberEntity,
          projectId: extra.projectId,
          project: extra.project,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.createAnnouncement,
      builder: (context, _) => const CreateAnnouncementScreen(),
    ),
    GoRoute(
      path: AppRoutes.leaderProjectSettings,
      builder: (context, state) {
        final extra = state.extra;
        if (extra is! LeaderProjectSettingsRouteArgs) {
          return invalidRouteScreen();
        }
        return LeaderProjectSettingsScreen(projectId: extra.projectId);
      },
    ),
    GoRoute(
      path: AppRoutes.joinRequests,
      builder: (context, state) {
        final extra = state.extra;
        if (extra is! JoinRequestsRouteArgs) return invalidRouteScreen();
        return JoinRequestsScreen(
          projectId: extra.projectId,
          onRefreshProjectDetail: extra.onRefreshProjectDetail,
        );
      },
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
          projectId: extra.projectId,
          isLeaderMode: extra.isLeaderMode,
          screenTitle: extra.screenTitle,
          project: extra.project,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.groupMembers,
      builder: (context, state) {
        final extra = state.extra;
        if (extra is! GroupMembersRouteArgs) return invalidRouteScreen();
        return GroupMembersScreen(
          members: extra.members,
          projectId: extra.projectId,
          project: extra.project,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.myBorrowRequest,
      builder: (context, state) {
        final extra = state.extra;
        if (extra is! MyBorrowRequestRouteArgs) return invalidRouteScreen();
        return MyBorrowRequestScreen(args: extra);
      },
    ),
    GoRoute(
      path: AppRoutes.projectFundsHistory,
      builder: (context, state) {
        final extra = state.extra;
        if (extra is! ProjectFundsHistoryRouteArgs) return invalidRouteScreen();
        return ProjectFundsHistoryScreen(args: extra);
      },
    ),
    GoRoute(
      path: AppRoutes.markProjectSuccessful,
      builder: (context, state) {
        final extra = state.extra;
        if (extra is! MarkSuccessfulRouteArgs) return invalidRouteScreen();
        return MarkProjectSuccessfulScreen(
          projectId: extra.projectId,
          memberCount: extra.memberCount,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.stopContributions,
      builder: (context, state) {
        final extra = state.extra;
        if (extra is! StopContributionsRouteArgs) return invalidRouteScreen();
        return StopContributionsScreen(projectId: extra.projectId);
      },
    ),
    GoRoute(
      path: AppRoutes.votingWindow,
      builder: (context, state) {
        final extra = state.extra;
        if (extra is! VotingWindowRouteArgs) return invalidRouteScreen();
        return VotingWindowScreen(
          projectId: extra.projectId,
          flowKind: extra.flowKind,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.leaderVoteStarted,
      builder: (context, state) => const LeaderVoteStartedScreen(),
    ),
    GoRoute(
      path: AppRoutes.cancelProject,
      builder: (context, state) {
        final extra = state.extra;
        if (extra is! CancelProjectRouteArgs) return invalidRouteScreen();
        return CancelProjectScreen(
          projectId: extra.projectId,
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
    GoRoute(
      path: AppRoutes.userVoteOutcome,
      builder: (context, state) {
        final extra = state.extra;
        if (extra is! MemberVoteOutcomeRouteArgs) return invalidRouteScreen();
        return MemberVoteOutcomeScreen(args: extra);
      },
    ),
    GoRoute(
      path: AppRoutes.userInvestmentProjectDetail,
      builder: (context, state) {
        final extra = state.extra;
        if (extra is! UserInvestmentUiSnapshot) return invalidRouteScreen();
        return UserProjectDetailScreen(snapshot: extra);
      },
    ),
    GoRoute(
      path: AppRoutes.userInvestmentReturns,
      builder: (context, state) {
        final extra = state.extra;
        if (extra is InvestmentReturnsRouteArgs) {
          return UserInvestmentReturnsScreen(data: extra.data);
        }
        if (extra is UserInvestmentUiSnapshot) {
          return UserInvestmentReturnsScreen(
            data: InvestmentReturnsUiData.fromLegacySnapshot(extra),
          );
        }
        return invalidRouteScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.leaderDistributeFunds,
      builder: (context, state) {
        final extra = state.extra;
        if (extra is InvestmentReturnsRouteArgs) {
          return LeaderDistributeFundsScreen(data: extra.data);
        }
        return invalidRouteScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.leaderInvestmentDistribution,
      builder: (context, state) {
        final extra = state.extra;
        if (extra is InvestmentDistributionRouteArgs) {
          return InvestmentDistributionScreen(data: extra.data);
        }
        return invalidRouteScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.leaderInvestmentDistributionSuccess,
      builder: (context, state) {
        final extra = state.extra;
        if (extra is InvestmentDistributionSuccessRouteArgs) {
          return InvestmentFundsDistributedSuccessScreen(args: extra);
        }
        return invalidRouteScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.userInvestmentFundsHistory,
      builder: (context, state) {
        final extra = state.extra;
        if (extra is! UserInvestmentUiSnapshot) return invalidRouteScreen();
        return UserProjectFundsHistoryScreen(snapshot: extra);
      },
    ),
    GoRoute(
      path: AppRoutes.leaveProjectWarning,
      builder: (context, state) {
        final extra = state.extra;
        if (extra is LeaveProjectRouteArgs) {
          return LeaveProjectWarningScreen(args: extra);
        }
        if (extra is UserInvestmentUiSnapshot) {
          return LeaveProjectWarningScreen(
            args: LeaveProjectRouteArgs(
              projectId: extra.projectName,
              projectName: extra.projectName,
            ),
          );
        }
        return invalidRouteScreen();
      },
    ),
  ];
}

