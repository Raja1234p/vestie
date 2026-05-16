import 'package:vestie/app/router/route_args/project_detail_flow_args.dart';
import 'package:vestie/features/project_detail/domain/entities/borrow_request_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/presentation/navigation/project_detail_navigation_helpers.dart';

/// Builds [MyBorrowRequestRouteArgs] for the member My Borrow Request screen.
class MyBorrowRequestArgsBuilder {
  MyBorrowRequestArgsBuilder._();

  static MyBorrowRequestRouteArgs fromProject(ProjectDetailEntity project) {
    // Replace with viewer's active request + history when API is available.
    final active = _activeRequestFromProject(project);
    return MyBorrowRequestRouteArgs(
      projectId: project.id,
      walletFlowArgs: ProjectDetailNavigationHelpers.walletArgs(project),
      activeRequest: active,
      history: active != null ? _previewHistory() : const [],
    );
  }

  static BorrowRequestEntity? _activeRequestFromProject(
    ProjectDetailEntity project,
  ) {
    // TODO: map viewer's pending borrow request from project detail API.
    return null;
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
