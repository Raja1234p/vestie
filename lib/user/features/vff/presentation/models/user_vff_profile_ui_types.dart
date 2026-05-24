// VFF peer profile payloads — enums plus lightweight row models.

enum UserVffProfileBadgeMode { member, vffVerified }

enum UserVffProfileFooterMode { sendRequest, requestSent, followingSheet }

enum UserVffMetricsLayout { contributedPair, trioCounters }

enum UserVffJoinedProjectAction {
  join,
  joined,
  requestToJoin,
  requestSentChip,
}

class UserVffTxRowUi {
  final String title;
  final String date;
  final String amountDisplay;
  final bool positive;

  const UserVffTxRowUi({
    required this.title,
    required this.date,
    required this.amountDisplay,
    this.positive = true,
  });
}

class UserVffJoinedProjectRowUi {
  final String projectId;
  final String title;
  final int memberCount;
  final UserVffJoinedProjectAction action;

  const UserVffJoinedProjectRowUi({
    this.projectId = '',
    required this.title,
    required this.memberCount,
    required this.action,
  });
}

class UserVffMetricsUi {
  final String contributedDisplay;
  final String contributionsDisplay;
  final String? projectsDisplay;

  const UserVffMetricsUi({
    required this.contributedDisplay,
    required this.contributionsDisplay,
    this.projectsDisplay,
  });
}
