import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/user_vff_hub_ui_model.dart';

/// Local list state for the full “VFF Requests” route (prototype).
final class UserVffIncomingRequestListCubit
    extends Cubit<List<UserVffIncomingRequestUi>> {
  UserVffIncomingRequestListCubit(List<UserVffIncomingRequestUi> seed)
      : super(List<UserVffIncomingRequestUi>.of(seed));

  void remove(UserVffIncomingRequestUi row) {
    emit(state.where((e) => e.id != row.id).toList());
  }
}
