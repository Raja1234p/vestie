// Aggregated peer profile surfaced from VFF / invitations flows.
export 'user_vff_profile_ui_types.dart';

import 'user_vff_profile_ui_types.dart';

class UserVffProfileUiModel {
  final String id;
  final String usernameHandle;
  final String displayName;
  final String initials;
  final UserVffProfileBadgeMode badgeMode;
  final UserVffMetricsLayout metricsLayout;
  final UserVffMetricsUi metrics;
  final List<UserVffTxRowUi>? transactions;
  final List<UserVffJoinedProjectRowUi>? joinedProjects;
  final UserVffProfileFooterMode footerMode;

  const UserVffProfileUiModel({
    required this.id,
    required this.usernameHandle,
    required this.displayName,
    required this.initials,
    required this.badgeMode,
    this.metricsLayout = UserVffMetricsLayout.contributedPair,
    required this.metrics,
    this.transactions,
    this.joinedProjects,
    this.footerMode = UserVffProfileFooterMode.sendRequest,
  });

  factory UserVffProfileUiModel.demoOliviaInitial() => UserVffProfileUiModel(
        id: 'olivia',
        usernameHandle: 'olivia-r',
        displayName: 'Olivia Rojer',
        initials: 'OR',
        badgeMode: UserVffProfileBadgeMode.member,
        metrics: const UserVffMetricsUi(
          contributedDisplay: '\$1,200',
          contributionsDisplay: '3',
        ),
        footerMode: UserVffProfileFooterMode.sendRequest,
        transactions: const [
          UserVffTxRowUi(
            title: 'Family Vacation Fund…',
            date: 'Mar 11',
            amountDisplay: '+\$400',
          ),
          UserVffTxRowUi(
            title: 'Weekend Pot…',
            date: 'Mar 03',
            amountDisplay: '+\$420',
          ),
        ],
      );

  factory UserVffProfileUiModel.demoOliviaRequestSent() =>
      UserVffProfileUiModel(
        id: 'olivia',
        usernameHandle: 'olivia-r',
        displayName: 'Olivia Rojer',
        initials: 'OR',
        badgeMode: UserVffProfileBadgeMode.member,
        metrics: UserVffProfileUiModel.demoOliviaInitial().metrics,
        footerMode: UserVffProfileFooterMode.requestSent,
        transactions:
            UserVffProfileUiModel.demoOliviaInitial().transactions ?? const [],
      );

  factory UserVffProfileUiModel.demoJulianLee() => UserVffProfileUiModel(
        id: 'julian',
        usernameHandle: 'julianl',
        displayName: 'Julian Lee',
        initials: 'JL',
        badgeMode: UserVffProfileBadgeMode.member,
        metrics: const UserVffMetricsUi(
          contributedDisplay: '\$940',
          contributionsDisplay: '2',
        ),
        footerMode: UserVffProfileFooterMode.sendRequest,
        transactions: const [
          UserVffTxRowUi(
            title: 'Coffee Run Pot…',
            date: 'Apr 09',
            amountDisplay: '+\$40',
          ),
        ],
      );

  factory UserVffProfileUiModel.demoOliviaFollowing() => UserVffProfileUiModel(
        id: 'olivia',
        usernameHandle: 'olivia-r',
        displayName: 'Olivia Rojer',
        initials: 'OR',
        badgeMode: UserVffProfileBadgeMode.vffVerified,
        metricsLayout: UserVffMetricsLayout.trioCounters,
        metrics: const UserVffMetricsUi(
          contributedDisplay: '\$1,200',
          contributionsDisplay: '24',
          projectsDisplay: '5',
        ),
        footerMode: UserVffProfileFooterMode.followingSheet,
        joinedProjects: const [
          UserVffJoinedProjectRowUi(
            title: 'Paris Trip 2025',
            memberCount: 8,
            action: UserVffJoinedProjectAction.join,
          ),
          UserVffJoinedProjectRowUi(
            title: 'Paris Trip 2025',
            memberCount: 8,
            action: UserVffJoinedProjectAction.joined,
          ),
          UserVffJoinedProjectRowUi(
            title: 'Europe Trip 2025',
            memberCount: 4,
            action: UserVffJoinedProjectAction.requestToJoin,
          ),
          UserVffJoinedProjectRowUi(
            title: 'Invest Trip',
            memberCount: 2,
            action: UserVffJoinedProjectAction.requestSentChip,
          ),
        ],
      );
}
