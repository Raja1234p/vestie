import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/features/project_detail/domain/entities/member_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';

/// One row in the leader “View Success Votes” member list (Figma).
enum LeaderMemberVoteStatus { agreed, disagreed, waiting }

class LeaderSuccessVoteMemberRow {
  final String name;
  final LeaderMemberVoteStatus status;

  const LeaderSuccessVoteMemberRow({required this.name, required this.status});
}

/// Leader monitors an active success vote (Figma Post-Success — voting window).
class LeaderSuccessVoteProgressUiData {
  final int agreedCount;
  final int disagreedCount;
  final int notVotedCount;
  final int majorityRequired;
  final int totalMembers;
  final Duration remaining;
  final List<LeaderSuccessVoteMemberRow> members;

  /// Investment phase 1 — stop-contributions vote (Figma majority banner copy).
  final bool isStopContributionsVote;

  /// Group leader only — Continue contribution on the monitor screen.
  final bool showContinueContributions;

  final String continueContributionLabel;

  const LeaderSuccessVoteProgressUiData({
    required this.agreedCount,
    required this.disagreedCount,
    required this.notVotedCount,
    required this.majorityRequired,
    required this.totalMembers,
    required this.remaining,
    required this.members,
    this.isStopContributionsVote = false,
    this.showContinueContributions = false,
    this.continueContributionLabel = AppStrings.btnContinueContribution,
  });

  /// Figma-style preview until vote-status API is wired.
  factory LeaderSuccessVoteProgressUiData.preview({
    ProjectDetailEntity? project,
    bool isStopContributionsVote = true,
  }) {
    final total = project != null && project.members.isNotEmpty
        ? project.members.length
        : 7;
    final majority = total <= 1 ? 1 : (total / 2).floor() + 1;

    final previewMembers = project != null && project.members.isNotEmpty
        ? _previewStatusesForMembers(project.members)
        : _defaultPreviewMembers;

    return LeaderSuccessVoteProgressUiData(
      agreedCount: 2,
      disagreedCount: 1,
      notVotedCount: 5,
      majorityRequired: majority,
      totalMembers: total,
      remaining: const Duration(hours: 31, minutes: 22, seconds: 9),
      members: previewMembers,
      isStopContributionsVote: isStopContributionsVote,
    );
  }

  static List<LeaderSuccessVoteMemberRow> _previewStatusesForMembers(
    List<MemberEntity> members,
  ) {
    const pattern = [
      LeaderMemberVoteStatus.agreed,
      LeaderMemberVoteStatus.disagreed,
      LeaderMemberVoteStatus.agreed,
      LeaderMemberVoteStatus.waiting,
      LeaderMemberVoteStatus.waiting,
      LeaderMemberVoteStatus.waiting,
      LeaderMemberVoteStatus.waiting,
    ];
    return List.generate(members.length, (i) {
      final member = members[i];
      final name = member.name.isNotEmpty ? member.name : member.username;
      return LeaderSuccessVoteMemberRow(
        name: name,
        status: pattern[i % pattern.length],
      );
    });
  }

  static const List<LeaderSuccessVoteMemberRow> _defaultPreviewMembers = [
    LeaderSuccessVoteMemberRow(
      name: 'Anna T.',
      status: LeaderMemberVoteStatus.agreed,
    ),
    LeaderSuccessVoteMemberRow(
      name: 'Marco B.',
      status: LeaderMemberVoteStatus.disagreed,
    ),
    LeaderSuccessVoteMemberRow(
      name: 'Sarah K.',
      status: LeaderMemberVoteStatus.agreed,
    ),
    LeaderSuccessVoteMemberRow(
      name: 'Mike R.',
      status: LeaderMemberVoteStatus.waiting,
    ),
    LeaderSuccessVoteMemberRow(
      name: 'Tom W.',
      status: LeaderMemberVoteStatus.waiting,
    ),
    LeaderSuccessVoteMemberRow(
      name: 'Linda B.',
      status: LeaderMemberVoteStatus.waiting,
    ),
    LeaderSuccessVoteMemberRow(
      name: 'James P.',
      status: LeaderMemberVoteStatus.waiting,
    ),
  ];
}
