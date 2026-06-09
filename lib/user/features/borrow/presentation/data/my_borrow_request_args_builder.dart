import 'package:vestie/app/router/route_args/project_detail_flow_args.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/presentation/navigation/project_detail_navigation.dart';

/// Builds [MyBorrowRequestRouteArgs] for route navigation metadata.
///
/// Screen content loads from `GET …/borrow-requests/mine/screen` via
/// [MyBorrowRequestCubit] (see `project_routes.dart`).
class MyBorrowRequestArgsBuilder {
  MyBorrowRequestArgsBuilder._();

  static MyBorrowRequestRouteArgs fromProject(ProjectDetailEntity project) {
    return MyBorrowRequestRouteArgs(
      projectId: project.id,
      projectName: project.name,
      walletFlowArgs: ProjectDetailNavigation.walletArgs(project),
      borrowDisabledForViewer: project.isBorrowDisabledForViewer,
    );
  }
}
