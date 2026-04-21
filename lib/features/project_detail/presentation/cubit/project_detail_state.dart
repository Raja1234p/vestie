/// Tab options on the Project Detail screen.
enum ProjectDetailTab { borrowRequests, members }

enum ProjectDetailViewStatus { loading, loaded, error }

/// State for ProjectDetailCubit.
class ProjectDetailState {
  final ProjectDetailTab activeTab;
  final ProjectDetailViewStatus status;
  final bool actionBusy;
  final String? errorMessage;

  const ProjectDetailState({
    this.activeTab = ProjectDetailTab.borrowRequests,
    this.status = ProjectDetailViewStatus.loaded,
    this.actionBusy = false,
    this.errorMessage,
  });

  ProjectDetailState copyWith({
    ProjectDetailTab? activeTab,
    ProjectDetailViewStatus? status,
    bool? actionBusy,
    String? errorMessage,
  }) {
    return ProjectDetailState(
      activeTab: activeTab ?? this.activeTab,
      status: status ?? this.status,
      actionBusy: actionBusy ?? this.actionBusy,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
