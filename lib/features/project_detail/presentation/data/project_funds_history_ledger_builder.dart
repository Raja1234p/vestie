import 'package:vestie/app/router/route_args/project_detail_flow_args.dart';
import 'package:vestie/user/features/home/domain/entities/project_category_extensions.dart';

import '../../domain/entities/project_detail_entity.dart';

/// Builds [ProjectFundsHistoryRouteArgs] from project detail (API + fallbacks).
class ProjectFundsHistoryLedgerBuilder {
  ProjectFundsHistoryLedgerBuilder._();

  static ProjectFundsHistoryRouteArgs fromProject(ProjectDetailEntity project) {
    final totalContribution = project.members.fold<double>(
      0,
      (sum, m) => sum + m.contributedAmount,
    );
    final activeBorrows = project.borrowRequests.fold<double>(
      0,
      (sum, r) => sum + r.requestedAmount,
    );

    final isInvestment = project.category.isInvestment;
    final entries = _entriesFromProject(project);
    final preview = isInvestment
        ? _previewEntriesInvestment()
        : _previewEntriesPooled();

    return ProjectFundsHistoryRouteArgs(
      projectId: project.id,
      currentPotBalance: project.currentAmount,
      totalContribution: totalContribution,
      activeBorrows: activeBorrows,
      entries: entries.isNotEmpty ? entries : preview,
      isInvestment: isInvestment,
    );
  }

  static List<ProjectFundsHistoryEntryArgs> _entriesFromProject(
    ProjectDetailEntity project,
  ) {
    // Replace with ledger API when available.
    return const [];
  }

  /// Investment project funds history (Figma).
  static List<ProjectFundsHistoryEntryArgs> _previewEntriesInvestment() {
    return const [
      ProjectFundsHistoryEntryArgs(
        memberName: 'Lien',
        dateLabel: 'Mar 12',
        amount: 500,
      ),
      ProjectFundsHistoryEntryArgs(
        memberName: 'John',
        dateLabel: 'Mar 12',
        amount: 650,
      ),
    ];
  }

  /// Vacation / emergency pooled pot (contributions + borrows).
  static List<ProjectFundsHistoryEntryArgs> _previewEntriesPooled() {
    return const [
      ProjectFundsHistoryEntryArgs(
        memberName: 'Lien',
        dateLabel: 'Mar 12',
        amount: 500,
      ),
      ProjectFundsHistoryEntryArgs(
        memberName: 'Olivia',
        dateLabel: 'Mar 11',
        amount: -115,
      ),
      ProjectFundsHistoryEntryArgs(
        memberName: 'John',
        dateLabel: 'Mar 12',
        amount: 650,
      ),
    ];
  }
}
