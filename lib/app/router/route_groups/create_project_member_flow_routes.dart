import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/user/features/create_project_member_fund/presentation/models/create_project_fund_draft.dart';
import 'package:vestie/user/features/create_project_member_fund/presentation/models/create_project_status_screen_args.dart';
import 'package:vestie/user/features/create_project_member_fund/presentation/pages/create_project_contribution_progress_screen.dart';
import 'package:vestie/user/features/create_project_member_fund/presentation/pages/create_project_emergency_setup_screen.dart';
import 'package:vestie/user/features/create_project_member_fund/presentation/pages/create_project_fund_detail_screen.dart';
import 'package:vestie/user/features/create_project_member_fund/presentation/pages/create_project_summary_screen.dart';
import 'package:vestie/user/features/create_project_member_fund/presentation/pages/create_project_status_screen.dart';
import 'package:vestie/user/features/create_project_member_fund/presentation/pages/create_project_vacation_setup_screen.dart';

import '../app_routes.dart';

const Widget _invalidRouteScaffold = Scaffold(
  body: Center(child: Text(AppStrings.routeNotFound)),
);

/// Vacation & Emergency member walkthrough routes (pure UI — no APIs).
List<RouteBase> buildCreateProjectMemberFlowRoutes() {
  return [
    GoRoute(
      path: AppRoutes.createProjectVacationSetup,
      builder: (context, _) => const CreateProjectVacationSetupScreen(),
    ),
    GoRoute(
      path: AppRoutes.createProjectEmergencySetup,
      builder: (context, _) => const CreateProjectEmergencySetupScreen(),
    ),
    GoRoute(
      path: AppRoutes.createProjectFundSummary,
      builder: (context, state) {
        final extra = state.extra;
        if (extra is! CreateProjectFundDraft) {
          return _invalidRouteScaffold;
        }
        return CreateProjectSummaryScreen(draft: extra);
      },
    ),
    GoRoute(
      path: AppRoutes.createProjectFundDetail,
      builder: (context, state) {
        final extra = state.extra;
        if (extra is! CreateProjectFundDraft) {
          return _invalidRouteScaffold;
        }
        return CreateProjectFundDetailScreen(draft: extra);
      },
    ),
    GoRoute(
      path: AppRoutes.createProjectFundContributionProgress,
      builder: (context, state) {
        final extra = state.extra;
        if (extra is! CreateProjectFundDraft) {
          return _invalidRouteScaffold;
        }
        return CreateProjectContributionProgressScreen(draft: extra);
      },
    ),
    GoRoute(
      path: AppRoutes.createProjectFundStatus,
      builder: (context, state) {
        final extra = state.extra;
        if (extra is! CreateProjectStatusScreenArgs) {
          return _invalidRouteScaffold;
        }
        return CreateProjectStatusScreen(args: extra);
      },
    ),
  ];
}
