import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/user_vff_hub_ui_model.dart';
import 'user_vff_hub_state.dart';

final class UserVffHubCubit extends Cubit<UserVffHubState> {
  UserVffHubCubit(UserVffHubUiModel hub)
      : super(UserVffHubState.fromHub(hub));

  void selectTab(int index) {
    emit(state.copyWith(tabIndex: index));
  }

  void dismissIncoming(UserVffIncomingRequestUi row) {
    final next = state.incomingVffRequests.where((e) => e.id != row.id).toList();
    emit(state.copyWith(incomingVffRequests: next));
  }

  void dismissGroup(UserVffGroupInviteUi row) {
    final next = state.groupInvitations.where((e) => e.id != row.id).toList();
    emit(state.copyWith(groupInvitations: next));
  }
}
