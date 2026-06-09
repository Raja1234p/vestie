part of 'project_detail_navigation.dart';

void _refreshProjectDetailAfterMemberFlow(
  BuildContext context, {
  required String projectId,
  required MemberDetailPopResult? result,
}) {
  if (result == null) return;
  if (!context.mounted) return;
  _reloadProjectDetailBloc(context, projectId: projectId);
}

Future<void> _reloadProjectDetailAndWait(
  BuildContext context, {
  required String projectId,
}) async {
  if (!context.mounted) return;
  try {
    await context.read<ProjectDetailBloc>().reloadDetailAndWait(projectId);
    return;
  } on ProviderNotFoundException {
    // Opened outside project detail.
  }
  await ProjectDetailReloadCoordinator.reload(projectId);
}

void _reloadProjectDetailBloc(
  BuildContext context, {
  required String projectId,
}) {
  if (!context.mounted) return;
  try {
    context.read<ProjectDetailBloc>().add(
      LoadProjectDetailEvent(projectId: projectId),
    );
  } on ProviderNotFoundException {
    // Opened outside project detail.
  }
}

Future<void> _openMyBorrowRequestAndRefresh(
  BuildContext context, {
  required ProjectDetailEntity project,
}) async {
  final changed = await context.push<bool>(
    AppRoutes.myBorrowRequest,
    extra: MyBorrowRequestArgsBuilder.fromProject(project),
  );
  if (!context.mounted || changed != true) return;
  await _refreshAfterBorrowSubmit(
    context,
    projectId: project.id,
    reloadDetail: false,
  );
}

Future<void> _refreshAfterBorrowSubmit(
  BuildContext context, {
  required String projectId,
  bool reloadDetail = true,
}) async {
  if (!context.mounted) return;
  try {
    context.read<ProjectDetailBloc>().add(
      const ChangeTabEvent(activeTab: ProjectDetailTab.borrowRequests),
    );
  } on ProviderNotFoundException {
    // Opened outside project detail.
  }
  if (reloadDetail) {
    await _reloadProjectDetailAndWait(context, projectId: projectId);
  }
}

void _refreshAfterContribution(
  BuildContext context, {
  required String projectId,
  required ContributionSubmitResultModel submitResult,
}) {
  HomeProjectListSync.recordContribution(
    projectId: projectId,
    projectPot: submitResult.projectPot,
  );
  if (!context.mounted) return;
  try {
    context.read<ProjectDetailBloc>().add(
      ApplyContributionSubmitResultEvent(
        projectId: projectId,
        projectPot: submitResult.projectPot,
        vffMemberUserIds: submitResult.vffMemberUserIds,
      ),
    );
  } on ProviderNotFoundException {
    // Opened outside project detail.
  }
}

void _sendVffRequestFromMemberRow(
  BuildContext context, {
  required MemberEntity member,
}) {
  sendMemberVffFromProjectDetail(context, member: member);
}
