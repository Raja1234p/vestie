/// UI row: “My VFFs” connection list.
class UserVffConnectionRowUi {
  final String id;
  final String name;
  final String initials;
  final String mutualLabel;
  /// Trailing chip “Request Sent” vs chevron.
  final bool isPendingSent;

  const UserVffConnectionRowUi({
    required this.id,
    required this.name,
    required this.initials,
    required this.mutualLabel,
    this.isPendingSent = false,
  });
}

/// Incoming VFF connection request (via a project).
class UserVffIncomingRequestUi {
  final String id;
  final String name;
  final String initials;
  final String viaProjectName;

  const UserVffIncomingRequestUi({
    required this.id,
    required this.name,
    required this.initials,
    required this.viaProjectName,
  });
}

enum UserVffGroupInviteKind {
  project,
  memberRequestJoin,
}

class UserVffGroupInviteUi {
  final String id;
  final UserVffGroupInviteKind kind;
  final String titleLine;
  /// For [UserVffGroupInviteKind.memberRequestJoin]; ignored for projects.
  final String personInitials;
  final String invitedByName;
  final int memberCount;

  const UserVffGroupInviteUi({
    required this.id,
    required this.kind,
    required this.titleLine,
    this.personInitials = '',
    required this.invitedByName,
    this.memberCount = 0,
  });
}

/// Hub snapshot (`/user/vff` + drill-down screens).
class UserVffHubUiModel {
  final List<UserVffConnectionRowUi> myVffConnections;
  final List<UserVffIncomingRequestUi> incomingVffRequests;
  final List<UserVffGroupInviteUi> groupInvitations;

  const UserVffHubUiModel({
    required this.myVffConnections,
    required this.incomingVffRequests,
    required this.groupInvitations,
  });

  List<UserVffIncomingRequestUi> get previewIncoming =>
      incomingVffRequests.take(3).toList(growable: false);

  List<UserVffGroupInviteUi> get previewGroup =>
      groupInvitations.take(3).toList(growable: false);

  static const UserVffHubUiModel empty = UserVffHubUiModel(
    myVffConnections: [],
    incomingVffRequests: [],
    groupInvitations: [],
  );

  static UserVffHubUiModel demoFilled() => UserVffHubUiModel(
        myVffConnections: const [
          UserVffConnectionRowUi(
            id: 'julian',
            name: 'Julian Lee',
            initials: 'JL',
            mutualLabel: '3 mutual projects',
          ),
          UserVffConnectionRowUi(
            id: 'olivia',
            name: 'Olivia Rojer',
            initials: 'OR',
            mutualLabel: '2 mutual projects',
            isPendingSent: true,
          ),
        ],
        incomingVffRequests: const [
          UserVffIncomingRequestUi(
            id: 'r1',
            name: 'Sara Malik',
            initials: 'SM',
            viaProjectName: 'Paris Trip 2025',
          ),
          UserVffIncomingRequestUi(
            id: 'r2',
            name: 'Noah Abbas',
            initials: 'NA',
            viaProjectName: 'Weekend Saving Pot',
          ),
        ],
        groupInvitations: const [
          UserVffGroupInviteUi(
            id: 'g1',
            kind: UserVffGroupInviteKind.project,
            titleLine: 'Paris Trip 2025',
            invitedByName: 'Alex Kim',
            memberCount: 8,
          ),
          UserVffGroupInviteUi(
            id: 'g2',
            kind: UserVffGroupInviteKind.memberRequestJoin,
            titleLine: 'Priya Rao',
            personInitials: 'PR',
            invitedByName: 'Alex Kim',
            memberCount: 0,
          ),
        ],
      );

  /// Empty My VFFs but keep requests previews (screenshot parity toggle).
  static UserVffHubUiModel demoEmptyMyVffs(UserVffHubUiModel base) =>
      UserVffHubUiModel(
        myVffConnections: const [],
        incomingVffRequests: base.incomingVffRequests,
        groupInvitations: base.groupInvitations,
      );

  static UserVffHubUiModel demoEmptyRequests(UserVffHubUiModel base) =>
      UserVffHubUiModel(
        myVffConnections: base.myVffConnections,
        incomingVffRequests: const [],
        groupInvitations: const [],
      );
}
