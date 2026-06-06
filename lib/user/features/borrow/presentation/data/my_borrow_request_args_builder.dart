import 'package:vestie/app/router/route_args/project_detail_flow_args.dart';
import 'package:vestie/features/project_detail/domain/entities/borrow_request_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/presentation/navigation/project_detail_navigation.dart';
import 'package:vestie/user/features/borrow/presentation/models/my_borrow_approved_ui_data.dart';

/// Builds [MyBorrowRequestRouteArgs] for the member My Borrow Request screen.
class MyBorrowRequestArgsBuilder {
  MyBorrowRequestArgsBuilder._();

  static MyBorrowRequestRouteArgs fromProject(ProjectDetailEntity project) {
    final active = _activeRequestFromProject(project);
    return MyBorrowRequestRouteArgs(
      projectId: project.id,
      projectName: project.name,
      walletFlowArgs: ProjectDetailNavigation.walletArgs(project),
      activeRequest: active,
      history: active != null ? _previewHistory() : const [],
      borrowDisabledForViewer: project.isBorrowDisabledForViewer,
    );
  }

  /// Dev / Figma preview — active borrow request until API is wired.
  static MyBorrowRequestRouteArgs previewActiveFromProject(
    ProjectDetailEntity project,
  ) {
    return MyBorrowRequestRouteArgs(
      projectId: project.id,
      projectName: project.name,
      walletFlowArgs: ProjectDetailNavigation.walletArgs(project),
      activeRequest: _previewActiveRequest(),
      history: _previewHistory(),
      borrowDisabledForViewer: project.isBorrowDisabledForViewer,
    );
  }

  static BorrowRequestEntity? _activeRequestFromProject(
    ProjectDetailEntity project,
  ) {
    // TODO: map viewer's pending borrow request from project detail API.
    return null;
  }

  /// Figma pending / request-sent state (My Borrow Request dev preview).
  static BorrowRequestEntity pendingPreviewRequest() => _previewActiveRequest();

  static List<MyBorrowHistoryEntry> pendingPreviewHistory() =>
      _previewHistory();

  /// Figma approved borrow — “My Borrow” repayment screen.
  static MyBorrowApprovedUiData approvedPreview() =>
      const MyBorrowApprovedUiData(
        borrowAmount: 300,
        borrowDateLabel: 'May 24, 2025',
        dueDateLabel: 'May 1, 2025',
        totalRepayment: 300,
        totalRepaymentDue: 345,
        penaltyPercent: 15,
        penaltyAmount: 45,
      );

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
      MyBorrowHistoryEntry(amount: 115, dateLabel: 'Mar 11', isApproved: true),
      MyBorrowHistoryEntry(amount: 500, dateLabel: 'Mar 11', isApproved: false),
    ];
  }
}
