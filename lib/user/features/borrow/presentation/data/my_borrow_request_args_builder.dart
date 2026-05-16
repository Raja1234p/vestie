import 'package:vestie/app/router/route_args/project_detail_flow_args.dart';
import 'package:vestie/features/project_detail/domain/entities/borrow_request_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/presentation/navigation/project_detail_navigation_helpers.dart';

/// Builds [MyBorrowRequestRouteArgs] for the member My Borrow Request screen.
class MyBorrowRequestArgsBuilder {
  MyBorrowRequestArgsBuilder._();

  static MyBorrowRequestRouteArgs fromProject(ProjectDetailEntity project) {
    final active = _activeRequestFromProject(project) ?? _previewActiveRequest();
    return MyBorrowRequestRouteArgs(
      projectId: project.id,
      walletFlowArgs: ProjectDetailNavigationHelpers.walletArgs(project),
      activeRequest: active,
      history: _previewHistory(),
    );
  }

  static BorrowRequestEntity? _activeRequestFromProject(
    ProjectDetailEntity project,
  ) {
    // TODO: map viewer's pending borrow request from project detail API.
    return null;
  }

  /// Figma active state preview until my-borrow-request API is wired.
  static BorrowRequestEntity _previewActiveRequest() {
    return const BorrowRequestEntity(
      id: 'preview-active',
      initials: 'ME',
      memberName: 'You',
      loanType: 'Education Loan',
      requestedAmount: 300,
      upvotes: 4,
      downvotes: 2,
    );
  }

  /// Figma preview history until my-borrow-history API is wired.
  static List<MyBorrowHistoryEntry> _previewHistory() {
    return const [
      MyBorrowHistoryEntry(
        amount: 115,
        dateLabel: 'Mar 11',
        isApproved: true,
      ),
      MyBorrowHistoryEntry(
        amount: 500,
        dateLabel: 'Mar 11',
        isApproved: false,
      ),
    ];
  }
}
