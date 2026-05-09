import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeSectionsState extends Equatable {
  final bool myProjectsExpanded;
  final bool joinedProjectsExpanded;

  const HomeSectionsState({
    this.myProjectsExpanded = true,
    this.joinedProjectsExpanded = true,
  });

  HomeSectionsState copyWith({
    bool? myProjectsExpanded,
    bool? joinedProjectsExpanded,
  }) {
    return HomeSectionsState(
      myProjectsExpanded: myProjectsExpanded ?? this.myProjectsExpanded,
      joinedProjectsExpanded:
          joinedProjectsExpanded ?? this.joinedProjectsExpanded,
    );
  }

  @override
  List<Object> get props => [myProjectsExpanded, joinedProjectsExpanded];
}

/// Controls expand/collapse state of the My Projects and Joined Projects sections.
class HomeSectionsCubit extends Cubit<HomeSectionsState> {
  HomeSectionsCubit() : super(const HomeSectionsState());

  void toggleMyProjects() =>
      emit(state.copyWith(myProjectsExpanded: !state.myProjectsExpanded));

  void toggleJoined() =>
      emit(state.copyWith(joinedProjectsExpanded: !state.joinedProjectsExpanded));
}
