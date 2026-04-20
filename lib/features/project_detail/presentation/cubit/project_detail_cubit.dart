import 'package:flutter_bloc/flutter_bloc.dart';
import 'project_detail_state.dart';

/// UI-only Cubit — manages the active tab on the Project Detail screen.
/// No API calls; use a Bloc for those.
class ProjectDetailCubit extends Cubit<ProjectDetailState> {
  ProjectDetailCubit() : super(const ProjectDetailState());

  void selectTab(ProjectDetailTab tab) =>
      emit(state.copyWith(activeTab: tab));
}
