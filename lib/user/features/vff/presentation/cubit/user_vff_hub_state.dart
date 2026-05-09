import 'package:equatable/equatable.dart';

import '../models/user_vff_hub_ui_model.dart';

final class UserVffHubState extends Equatable {
  static const previewCap = 2;

  final int tabIndex;
  final List<UserVffConnectionRowUi> myVffConnections;
  final List<UserVffIncomingRequestUi> incomingVffRequests;
  final List<UserVffGroupInviteUi> groupInvitations;

  const UserVffHubState({
    required this.tabIndex,
    required this.myVffConnections,
    required this.incomingVffRequests,
    required this.groupInvitations,
  });

  factory UserVffHubState.fromHub(UserVffHubUiModel hub) => UserVffHubState(
        tabIndex: 0,
        myVffConnections: List<UserVffConnectionRowUi>.of(hub.myVffConnections),
        incomingVffRequests:
            List<UserVffIncomingRequestUi>.of(hub.incomingVffRequests),
        groupInvitations: List<UserVffGroupInviteUi>.of(hub.groupInvitations),
      );

  UserVffHubState copyWith({
    int? tabIndex,
    List<UserVffConnectionRowUi>? myVffConnections,
    List<UserVffIncomingRequestUi>? incomingVffRequests,
    List<UserVffGroupInviteUi>? groupInvitations,
  }) {
    return UserVffHubState(
      tabIndex: tabIndex ?? this.tabIndex,
      myVffConnections: myVffConnections ?? this.myVffConnections,
      incomingVffRequests:
          incomingVffRequests ?? this.incomingVffRequests,
      groupInvitations: groupInvitations ?? this.groupInvitations,
    );
  }

  @override
  List<Object?> get props => [
        tabIndex,
        myVffConnections,
        incomingVffRequests,
        groupInvitations,
      ];
}
