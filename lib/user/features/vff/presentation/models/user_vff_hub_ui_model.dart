/// UI row: “My VFFs” connection list.
class UserVffConnectionRowUi {
  final String id;
  final String name;
  final String initials;
  final String? photoUrl;
  final String mutualLabel;
  /// Trailing chip “Request Sent” vs chevron.
  final bool isPendingSent;

  const UserVffConnectionRowUi({
    required this.id,
    required this.name,
    required this.initials,
    this.photoUrl,
    required this.mutualLabel,
    this.isPendingSent = false,
  });
}

/// Incoming VFF connection request (via a project).
class UserVffIncomingRequestUi {
  final String id;
  final String projectId;
  final String name;
  final String initials;
  final String? photoUrl;
  final String viaProjectName;

  const UserVffIncomingRequestUi({
    required this.id,
    this.projectId = '',
    required this.name,
    required this.initials,
    this.photoUrl,
    required this.viaProjectName,
  });
}

enum UserVffGroupInviteKind {
  project,
  memberRequestJoin,
}

class UserVffGroupInviteUi {
  final String id;
  final String projectId;
  final UserVffGroupInviteKind kind;
  final String titleLine;
  /// For [UserVffGroupInviteKind.memberRequestJoin]; ignored for projects.
  final String personInitials;
  final String invitedByName;
  final int memberCount;
  /// Project invite CTA: [AppStrings.userVffRequestToJoin] vs [AppStrings.btnJoin].
  final bool primaryIsRequestToJoin;

  const UserVffGroupInviteUi({
    required this.id,
    this.projectId = '',
    required this.kind,
    required this.titleLine,
    this.personInitials = '',
    required this.invitedByName,
    this.memberCount = 0,
    this.primaryIsRequestToJoin = false,
  });
}

/// Outgoing request / invite row in the hub Sent sub-tab.
class UserVffSentRowUi {
  final String id;
  final String titleLine;
  final String detailLine;
  final String statusLabel;

  const UserVffSentRowUi({
    required this.id,
    required this.titleLine,
    required this.detailLine,
    required this.statusLabel,
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
            id: 'julian-1',
            name: 'Julian Lee',
            initials: 'JL',
            mutualLabel: '3 mutual projects',
          ),
          UserVffConnectionRowUi(
            id: 'julian-2',
            name: 'Julian Lee',
            initials: 'JL',
            mutualLabel: '5 mutual projects',
          ),
          UserVffConnectionRowUi(
            id: 'julian-3',
            name: 'Julian Lee',
            initials: 'JL',
            mutualLabel: '3 mutual projects',
            isPendingSent: true,
          ),
        ],
        incomingVffRequests: const [
          UserVffIncomingRequestUi(
            id: 'r1',
            name: 'Julian Lee',
            initials: 'JL',
            viaProjectName: 'Paris Trip 2025',
          ),
          UserVffIncomingRequestUi(
            id: 'r2',
            name: 'Julian Lee',
            initials: 'JL',
            viaProjectName: 'Paris Trip 2025',
          ),
        ],
        groupInvitations: const [
          UserVffGroupInviteUi(
            id: 'g1',
            kind: UserVffGroupInviteKind.project,
            titleLine: 'Paris Trip 2025',
            invitedByName: 'Amir Malik',
            memberCount: 8,
          ),
          UserVffGroupInviteUi(
            id: 'g2',
            kind: UserVffGroupInviteKind.project,
            titleLine: 'Emergency funds for NCop',
            invitedByName: 'Amir Malik',
            primaryIsRequestToJoin: true,
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
