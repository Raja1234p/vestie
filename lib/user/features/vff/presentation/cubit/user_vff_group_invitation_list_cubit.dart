import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/user_vff_hub_ui_model.dart';

/// Local list state for the full “Group Invitations” route (prototype).
final class UserVffGroupInvitationListCubit
    extends Cubit<List<UserVffGroupInviteUi>> {
  UserVffGroupInvitationListCubit(List<UserVffGroupInviteUi> seed)
      : super(List<UserVffGroupInviteUi>.of(seed));

  void remove(UserVffGroupInviteUi row) {
    emit(state.where((e) => e.id != row.id).toList());
  }
}
