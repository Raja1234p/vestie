import 'package:equatable/equatable.dart';

import '../models/user_vff_hub_ui_model.dart';

import '../models/user_vff_inbox_action.dart';

enum UserVffHubLoadStatus { initial, loading, loaded, error }

enum UserVffHubRequestsLoadStatus { initial, loading, loaded, error }

final class UserVffHubState extends Equatable {
  final UserVffHubLoadStatus loadStatus;

  final UserVffHubRequestsLoadStatus requestsLoadStatus;

  final String? errorMessage;

  final String? requestsErrorMessage;

  final int tabIndex;

  final List<UserVffConnectionRowUi> myVffConnections;

  final List<UserVffIncomingRequestUi> incomingVffRequests;

  final List<UserVffGroupInviteUi> groupInvitations;

  final bool myVffsLoadingMore;
  final int myVffsCurrentPage;
  final int myVffsTotalCount;

  final UserVffInboxRowAction? actingRow;

  const UserVffHubState({
    this.loadStatus = UserVffHubLoadStatus.initial,

    this.requestsLoadStatus = UserVffHubRequestsLoadStatus.initial,

    this.errorMessage,

    this.requestsErrorMessage,

    this.tabIndex = 0,

    this.myVffConnections = const [],

    this.incomingVffRequests = const [],

    this.groupInvitations = const [],

    this.myVffsLoadingMore = false,

    this.myVffsCurrentPage = 0,

    this.myVffsTotalCount = 0,

    this.actingRow,
  });

  bool get myVffsHasMore => myVffConnections.length < myVffsTotalCount;

  factory UserVffHubState.fromHub(UserVffHubUiModel hub) => UserVffHubState(
    loadStatus: UserVffHubLoadStatus.loaded,

    requestsLoadStatus: UserVffHubRequestsLoadStatus.loaded,

    tabIndex: 0,

    myVffConnections: List<UserVffConnectionRowUi>.of(hub.myVffConnections),

    incomingVffRequests: List<UserVffIncomingRequestUi>.of(
      hub.incomingVffRequests,
    ),

    groupInvitations: List<UserVffGroupInviteUi>.of(hub.groupInvitations),
  );

  bool get isInboxActionBusy => actingRow != null;

  UserVffHubState copyWith({
    UserVffHubLoadStatus? loadStatus,

    UserVffHubRequestsLoadStatus? requestsLoadStatus,

    String? errorMessage,

    String? requestsErrorMessage,

    bool clearError = false,

    bool clearRequestsError = false,

    int? tabIndex,

    List<UserVffConnectionRowUi>? myVffConnections,

    List<UserVffIncomingRequestUi>? incomingVffRequests,

    List<UserVffGroupInviteUi>? groupInvitations,

    bool? myVffsLoadingMore,

    int? myVffsCurrentPage,

    int? myVffsTotalCount,

    UserVffInboxRowAction? actingRow,

    bool clearActingRow = false,
  }) {
    return UserVffHubState(
      loadStatus: loadStatus ?? this.loadStatus,

      requestsLoadStatus: requestsLoadStatus ?? this.requestsLoadStatus,

      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),

      requestsErrorMessage: clearRequestsError
          ? null
          : (requestsErrorMessage ?? this.requestsErrorMessage),

      tabIndex: tabIndex ?? this.tabIndex,

      myVffConnections: myVffConnections ?? this.myVffConnections,

      incomingVffRequests: incomingVffRequests ?? this.incomingVffRequests,

      groupInvitations: groupInvitations ?? this.groupInvitations,

      myVffsLoadingMore: myVffsLoadingMore ?? this.myVffsLoadingMore,

      myVffsCurrentPage: myVffsCurrentPage ?? this.myVffsCurrentPage,

      myVffsTotalCount: myVffsTotalCount ?? this.myVffsTotalCount,

      actingRow: clearActingRow ? null : (actingRow ?? this.actingRow),
    );
  }

  @override
  List<Object?> get props => [
    loadStatus,

    requestsLoadStatus,

    errorMessage,

    requestsErrorMessage,

    tabIndex,

    myVffConnections,

    incomingVffRequests,

    groupInvitations,

    myVffsLoadingMore,

    myVffsCurrentPage,

    myVffsTotalCount,

    actingRow,
  ];
}
