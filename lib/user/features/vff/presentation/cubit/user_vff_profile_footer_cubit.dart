import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/user_vff_profile_ui_model.dart';

final class UserVffProfileFooterState extends Equatable {
  final UserVffProfileFooterMode footerLocalOverride;

  const UserVffProfileFooterState({required this.footerLocalOverride});

  UserVffProfileFooterState copyWith({
    UserVffProfileFooterMode? footerLocalOverride,
  }) {
    return UserVffProfileFooterState(
      footerLocalOverride:
          footerLocalOverride ?? this.footerLocalOverride,
    );
  }

  @override
  List<Object?> get props => [footerLocalOverride];
}

final class UserVffProfileFooterCubit extends Cubit<UserVffProfileFooterState> {
  UserVffProfileFooterCubit(UserVffProfileUiModel profile)
      : super(UserVffProfileFooterState(
          footerLocalOverride: profile.footerMode,
        ));

  void markRequestSent() {
    emit(state.copyWith(
      footerLocalOverride: UserVffProfileFooterMode.requestSent,
    ));
  }

  bool showsRequestSentRibbon(UserVffProfileUiModel profile) =>
      profile.footerMode == UserVffProfileFooterMode.requestSent ||
      state.footerLocalOverride ==
          UserVffProfileFooterMode.requestSent;
}
