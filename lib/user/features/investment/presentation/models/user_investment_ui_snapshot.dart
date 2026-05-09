/// UI-only snapshot for the user investment journey (no backend contract).
class UserInvestmentMemberUi {
  final String name;
  final bool isActive;

  const UserInvestmentMemberUi({required this.name, this.isActive = true});
}

class UserInvestmentReturnsRowUi {
  final String periodLabel;
  final double amount;

  const UserInvestmentReturnsRowUi({
    required this.periodLabel,
    required this.amount,
  });
}

class UserInvestmentFundsRowUi {
  final String memberName;
  final String dateLabel;
  final double amount;

  const UserInvestmentFundsRowUi({
    required this.memberName,
    required this.dateLabel,
    required this.amount,
  });
}

class UserInvestmentUiSnapshot {
  final String projectName;
  final String? announcementOverride;
  /// Shown in the members modal title (`Project Members (n)`).
  final int headlineMemberCount;
  final List<UserInvestmentMemberUi> members;

  /// Goal line before any local “contributed” simulation (e.g. monthly target).
  final double monthlyGoalUsd;

  /// Shown after simulated contribution (“Raised”).
  final double raisedAfterContributeUsd;

  final DateTime nextContributionDate;

  final double totalReturnsUsd;
  final double investedAmountUsd;
  final List<UserInvestmentReturnsRowUi> returnsHistory;
  final double totalProjectFundsUsd;
  final List<UserInvestmentFundsRowUi> fundsHistory;

  /// Share invite (mock URL / deep link placeholder).
  final String inviteShareLink;

  const UserInvestmentUiSnapshot({
    required this.projectName,
    this.announcementOverride,
    this.headlineMemberCount = 0,
    required this.members,
    required this.monthlyGoalUsd,
    required this.raisedAfterContributeUsd,
    required this.nextContributionDate,
    required this.totalReturnsUsd,
    required this.investedAmountUsd,
    required this.returnsHistory,
    required this.totalProjectFundsUsd,
    required this.fundsHistory,
    required this.inviteShareLink,
  });

  /// Matches storyboard Vacation / Emergency investment-member examples.
  factory UserInvestmentUiSnapshot.demoInvestmentFlow() {
    return UserInvestmentUiSnapshot(
      projectName: 'Ocean View Trip',
      announcementOverride: null,
      headlineMemberCount: 20,
      members: const [
        UserInvestmentMemberUi(name: 'Pawan'),
        UserInvestmentMemberUi(name: 'Omair'),
        UserInvestmentMemberUi(name: 'Nitin'),
      ],
      monthlyGoalUsd: 2700,
      raisedAfterContributeUsd: 5000,
      nextContributionDate: DateTime(2025, 11, 24),
      totalReturnsUsd: 500,
      investedAmountUsd: 100,
      returnsHistory: const [
        UserInvestmentReturnsRowUi(periodLabel: 'October 24', amount: 10),
        UserInvestmentReturnsRowUi(periodLabel: 'September 24', amount: 8),
        UserInvestmentReturnsRowUi(periodLabel: 'August 24', amount: 12),
      ],
      totalProjectFundsUsd: 8240,
      fundsHistory: const [
        UserInvestmentFundsRowUi(memberName: 'Omair', dateLabel: '12 Oct 2024', amount: 500),
        UserInvestmentFundsRowUi(memberName: 'Pawan', dateLabel: '3 Oct 2024', amount: 320),
        UserInvestmentFundsRowUi(memberName: 'Nitin', dateLabel: '28 Sep 2024', amount: 200),
      ],
      inviteShareLink: 'https://vestie.app-invite/mock/ocean-trip',
    );
  }

  /// Empty members + no announcement payload (card uses default placeholder strings).
  factory UserInvestmentUiSnapshot.demoEmptyMembers() {
    final base = UserInvestmentUiSnapshot.demoInvestmentFlow();
    return UserInvestmentUiSnapshot(
      projectName: base.projectName,
      announcementOverride: null,
      headlineMemberCount: base.headlineMemberCount,
      members: const [],
      monthlyGoalUsd: base.monthlyGoalUsd,
      raisedAfterContributeUsd: base.raisedAfterContributeUsd,
      nextContributionDate: base.nextContributionDate,
      totalReturnsUsd: base.totalReturnsUsd,
      investedAmountUsd: base.investedAmountUsd,
      returnsHistory: base.returnsHistory,
      totalProjectFundsUsd: base.totalProjectFundsUsd,
      fundsHistory: base.fundsHistory,
      inviteShareLink: base.inviteShareLink,
    );
  }
}
