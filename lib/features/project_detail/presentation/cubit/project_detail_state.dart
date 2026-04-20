/// Tab options on the Project Detail screen.
enum ProjectDetailTab { borrowRequests, members }

/// State for ProjectDetailCubit — only tracks the active tab.
class ProjectDetailState {
  final ProjectDetailTab activeTab;

  const ProjectDetailState({this.activeTab = ProjectDetailTab.members});

  ProjectDetailState copyWith({ProjectDetailTab? activeTab}) =>
      ProjectDetailState(activeTab: activeTab ?? this.activeTab);
}
