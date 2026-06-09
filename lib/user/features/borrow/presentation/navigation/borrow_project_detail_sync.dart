import 'package:vestie/features/project_detail/presentation/project_detail_reload_coordinator.dart';

/// Reloads project detail (`GET /projects/{id}`) after borrow mutations and
/// **before** success dialogs / screens so detail is already in sync.
class BorrowProjectDetailSync {
  BorrowProjectDetailSync._();

  static Future<void> reloadBeforeSuccess(String projectId) {
    return ProjectDetailReloadCoordinator.reload(projectId);
  }
}
