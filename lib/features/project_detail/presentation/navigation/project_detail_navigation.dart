import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/leader/features/create_project/presentation/create_project_entry_mode.dart';
import 'package:vestie/leader/features/create_project/presentation/cubit/create_project_cubit.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/router/route_args/project_detail_flow_args.dart';
import '../../../../app/router/route_args/project_wallet_flow_args.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/common/app_toast.dart';
import '../../../../core/utils/invite_share_link_resolver.dart';
import '../../../../core/widgets/common/app_loading_dialog.dart';
import '../../../../core/widgets/common/app_invite_members_dialog.dart';
import '../../../../core/widgets/common/leader_action_menu.dart';
import '../../../../core/widgets/common/member_project_action_menu.dart';
import '../../domain/entities/member_entity.dart';
import '../widgets/project_member_vff_send_actions.dart';
import '../../domain/entities/project_detail_entity.dart';
import '../../domain/entities/create_announcement_route_args.dart';
import '../../domain/entities/project_detail_route_args.dart';
import '../models/investment_distribution_ui_data.dart';
import '../models/investment_returns_ui_data.dart';
import 'package:vestie/leader/features/project_detail/presentation/models/leader_success_vote_progress_ui_data.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_role.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_variant.dart';
import 'package:vestie/user/features/home/domain/entities/project_category_extensions.dart';
import '../widgets/distribute_funds_amount_sheet.dart';
import 'package:vestie/features/project_detail/presentation/project_detail_reload_coordinator.dart';
import 'package:vestie/features/projects/presentation/bloc/project_detail_bloc.dart';
import 'package:vestie/core/services/home_project_list_sync.dart';
import 'package:vestie/features/wallet/domain/wallet_balance_cache.dart';
import 'package:vestie/user/features/contributions/data/models/contribution_submit_result_model.dart';
import 'package:vestie/user/features/vff/presentation/mappers/invite_members_mapper.dart';
import '../data/project_funds_history_ledger_builder.dart';
import 'package:vestie/user/features/borrow/presentation/data/my_borrow_request_args_builder.dart';

part 'project_detail_navigation_route_args.dart';
part 'project_detail_navigation_refresh.dart';
part 'project_detail_navigation_router.dart';
part 'project_detail_navigation_leader.dart';
part 'project_detail_navigation_member.dart';

/// Shared navigation/route-arg helpers for project detail screens.
/// Keeps screen widgets focused on layout while preserving identical behavior.
class ProjectDetailNavigation {
  const ProjectDetailNavigation._();

  static ProjectWalletFlowArgs walletArgs(ProjectDetailEntity project) =>
      _walletArgs(project);

  static MemberDetailRouteArgs memberDetailArgs(
    ProjectDetailEntity project,
    MemberEntity member, {
    Future<void> Function()? onProjectMembersChanged,
  }) => _memberDetailArgs(
    project,
    member,
    onProjectMembersChanged: onProjectMembersChanged,
  );

  /// Member / CoLeader / GroupLeader — opens project member profile.
  static Future<MemberDetailPopResult?> openMemberProfile(
    BuildContext context, {
    required ProjectDetailEntity project,
    required MemberEntity member,
  }) => _openMemberProfile(context, project: project, member: member);

  /// Reloads `GET /projects/{id}` after member profile changes (remove, co-leader, etc.).
  static void refreshProjectDetailAfterMemberFlow(
    BuildContext context, {
    required String projectId,
    required MemberDetailPopResult? result,
  }) => _refreshProjectDetailAfterMemberFlow(
    context,
    projectId: projectId,
    result: result,
  );

  static Future<void> reloadProjectDetailAndWait(
    BuildContext context, {
    required String projectId,
  }) => _reloadProjectDetailAndWait(context, projectId: projectId);

  /// Merges contribute 201 `projectPot` / VFF ids, then reloads project detail.
  static Future<void> refreshAfterContribution(
    BuildContext context, {
    required String projectId,
    required ContributionSubmitResultModel submitResult,
  }) => _refreshAfterContribution(
    context,
    projectId: projectId,
    submitResult: submitResult,
  );

  /// Reloads project detail (pot + pending borrow list) after borrow submit.
  static Future<void> refreshAfterBorrowSubmit(
    BuildContext context, {
    required String projectId,
    bool reloadDetail = true,
  }) => _refreshAfterBorrowSubmit(
    context,
    projectId: projectId,
    reloadDetail: reloadDetail,
  );

  /// Sends a VFF request from a project member row (no profile screen).
  static void sendVffRequestFromMemberRow(
    BuildContext context, {
    required MemberEntity member,
  }) => _sendVffRequestFromMemberRow(context, member: member);

  static BorrowRequestsRouteArgs borrowRequestsArgs(
    ProjectDetailEntity project, {
    required bool isLeaderMode,
    String? screenTitle,
  }) => _borrowRequestsArgs(
    project,
    isLeaderMode: isLeaderMode,
    screenTitle: screenTitle,
  );

  static GroupMembersRouteArgs groupMembersArgs(ProjectDetailEntity project) =>
      _groupMembersArgs(project);

  static Future<void> openGroupMembers(
    BuildContext context, {
    required ProjectDetailEntity project,
  }) => _openGroupMembers(context, project: project);

  /// Pops success → distribution → distribute funds so the existing detail
  /// screen (and its bloc) is restored — avoids a full reload shimmer.
  static void popAfterFundsDistributed(
    BuildContext context, {
    required String projectId,
    String? projectName,
  }) => _popAfterFundsDistributed(
    context,
    projectId: projectId,
    projectName: projectName,
  );

  static void openFundsDistributedSuccess(
    BuildContext context, {
    required InvestmentDistributionUiData distributionData,
  }) =>
      _openFundsDistributedSuccess(context, distributionData: distributionData);

  static Future<void> openDistributeFundsFlow(
    BuildContext context, {
    required InvestmentReturnsUiData returnsData,
  }) => _openDistributeFundsFlow(context, returnsData: returnsData);

  static void openInvestmentReturns(
    BuildContext context, {
    required ProjectDetailEntity project,
  }) => _openInvestmentReturns(context, project: project);

  /// Group leader — active success vote monitor (Figma voting window).
  static void openLeaderViewSuccessVotes(
    BuildContext context, {
    required ProjectDetailEntity project,
  }) => _openLeaderViewSuccessVotes(context, project: project);

  /// Temporary preview — member/co-leader cast vote (give vote).
  static void openCastVotePreview(
    BuildContext context, {
    required ProjectDetailEntity project,
  }) => _openCastVotePreview(context, project: project);

  /// @deprecated Use [openCastVotePreview].
  static void openSuccessVoteScreenPreview(
    BuildContext context, {
    required ProjectDetailEntity project,
  }) => openCastVotePreview(context, project: project);

  /// Temporary preview — member vote outcome (approved / rejected).
  static void openMemberVoteOutcomePreview(
    BuildContext context, {
    required ProjectDetailEntity project,
    required bool approved,
  }) => _openMemberVoteOutcomePreview(
    context,
    project: project,
    approved: approved,
  );

  /// Temporary preview — investment GL stop-contributions vote rejected.
  static void openStopContributionsVoteRejectedPreview(
    BuildContext context, {
    required ProjectDetailEntity project,
  }) => _openStopContributionsVoteRejectedPreview(context, project: project);

  static Future<void> openInviteMembers(
    BuildContext context, {
    required ProjectDetailEntity project,
  }) => _openInviteMembers(context, project: project);

  static Future<void> handleLeaderAction(
    BuildContext context, {
    required ProjectDetailEntity project,
    required LeaderMenuAction action,
    bool refreshHomeOnPop = false,
    bool refreshDiscoverOnPop = false,
  }) => _handleLeaderAction(
    context,
    project: project,
    action: action,
    refreshHomeOnPop: refreshHomeOnPop,
    refreshDiscoverOnPop: refreshDiscoverOnPop,
  );

  static ProjectFundsHistoryRouteArgs fundsHistoryArgs(
    ProjectDetailEntity project,
  ) => _fundsHistoryArgs(project);

  static Future<void> handleMemberAction(
    BuildContext context, {
    required ProjectDetailEntity project,
    required MemberProjectMenuAction action,
    bool refreshHomeOnPop = false,
    bool refreshDiscoverOnPop = false,
  }) => _handleMemberAction(
    context,
    project: project,
    action: action,
    refreshHomeOnPop: refreshHomeOnPop,
    refreshDiscoverOnPop: refreshDiscoverOnPop,
  );
}
