import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';

/// Category-specific strings for the cast-vote screen (member & co-leader).
class SuccessVoteCastCopy {
  final String pendingBannerTitle;
  final String pendingBannerBody;
  final String agreedTitle;
  final String agreedBody;
  final String disagreedTitle;
  final String disagreedBody;
  final String deadlineLabel;
  final String statGoalLabel;
  final String statMembersLabel;
  final String totalRaisedLabel;
  final String memberVotesLabel;
  final String thumbsUpLabel;
  final String thumbsDownLabel;
  final String notVotedLabel;
  final String voteQuestion;
  final String voteYesLabel;
  final String voteNoLabel;

  const SuccessVoteCastCopy({
    required this.pendingBannerTitle,
    required this.pendingBannerBody,
    required this.agreedTitle,
    required this.agreedBody,
    required this.disagreedTitle,
    required this.disagreedBody,
    required this.deadlineLabel,
    required this.statGoalLabel,
    required this.statMembersLabel,
    required this.totalRaisedLabel,
    required this.memberVotesLabel,
    required this.thumbsUpLabel,
    required this.thumbsDownLabel,
    required this.notVotedLabel,
    required this.voteQuestion,
    required this.voteYesLabel,
    required this.voteNoLabel,
  });

  static SuccessVoteCastCopy forCategory(ProjectCategory category) {
    return switch (category) {
      ProjectCategory.vacations => _vacation,
      ProjectCategory.emergency => _emergency,
      ProjectCategory.investment => _investmentStopContributions,
    };
  }

  /// Member vs co-leader — only the pending banner body differs on vacation/emergency.
  ///
  /// Investment has two vote phases: stop-contributions (phase 1) vs mark-as-successful
  /// (phase 2). Each phase has dedicated Figma copy.
  static SuccessVoteCastCopy forViewer({
    required ProjectCategory category,
    required bool isCoLeader,
    bool isInvestmentStopContributionsVote = false,
    bool isInvestmentMarkSuccessfulVote = false,
  }) {
    if (category == ProjectCategory.investment) {
      if (isInvestmentStopContributionsVote) {
        return _investmentStopContributions;
      }
      if (isInvestmentMarkSuccessfulVote) {
        return _investmentMarkSuccessful;
      }
      if (!isCoLeader) return _vacation;
      return _vacationCoLeader;
    }
    if (!isCoLeader) return forCategory(category);
    return switch (category) {
      ProjectCategory.vacations => _vacationCoLeader,
      ProjectCategory.emergency => _emergencyCoLeader,
      ProjectCategory.investment => _investmentStopContributions,
    };
  }

  static const SuccessVoteCastCopy _vacation = SuccessVoteCastCopy(
    pendingBannerTitle: AppStrings.successVoteCastVacationPendingBannerTitle,
    pendingBannerBody: AppStrings.successVoteCastVacationPendingBannerBody,
    agreedTitle: AppStrings.successVoteCastVacationAgreedTitle,
    agreedBody: AppStrings.successVoteCastVacationAgreedBody,
    disagreedTitle: AppStrings.successVoteCastVacationDisagreedTitle,
    disagreedBody: AppStrings.successVoteCastVacationDisagreedBody,
    deadlineLabel: AppStrings.successVoteCastDeadlineLabel,
    statGoalLabel: AppStrings.successVoteCastStatGoal,
    statMembersLabel: AppStrings.successVoteCastStatMembers,
    totalRaisedLabel: AppStrings.successVoteCastTotalRaised,
    memberVotesLabel: AppStrings.successVoteCastMemberVotesLabel,
    thumbsUpLabel: AppStrings.successVoteCastThumbsUp,
    thumbsDownLabel: AppStrings.successVoteCastThumbsDown,
    notVotedLabel: AppStrings.successVoteCastNotYetVotedLabel,
    voteQuestion: AppStrings.successVoteCastVacationVoteQuestion,
    voteYesLabel: AppStrings.successVoteCastVacationVoteYes,
    voteNoLabel: AppStrings.successVoteCastVacationVoteNo,
  );

  static const SuccessVoteCastCopy _vacationCoLeader = SuccessVoteCastCopy(
    pendingBannerTitle: AppStrings.successVoteCastVacationPendingBannerTitle,
    pendingBannerBody: AppStrings.successVoteCastVacationCoLeaderPendingBannerBody,
    agreedTitle: AppStrings.successVoteCastVacationAgreedTitle,
    agreedBody: AppStrings.successVoteCastVacationAgreedBody,
    disagreedTitle: AppStrings.successVoteCastVacationDisagreedTitle,
    disagreedBody: AppStrings.successVoteCastVacationDisagreedBody,
    deadlineLabel: AppStrings.successVoteCastDeadlineLabel,
    statGoalLabel: AppStrings.successVoteCastStatGoal,
    statMembersLabel: AppStrings.successVoteCastStatMembers,
    totalRaisedLabel: AppStrings.successVoteCastTotalRaised,
    memberVotesLabel: AppStrings.successVoteCastMemberVotesLabel,
    thumbsUpLabel: AppStrings.successVoteCastThumbsUp,
    thumbsDownLabel: AppStrings.successVoteCastThumbsDown,
    notVotedLabel: AppStrings.successVoteCastNotYetVotedLabel,
    voteQuestion: AppStrings.successVoteCastVacationVoteQuestion,
    voteYesLabel: AppStrings.successVoteCastVacationVoteYes,
    voteNoLabel: AppStrings.successVoteCastVacationVoteNo,
  );

  static const SuccessVoteCastCopy _emergency = SuccessVoteCastCopy(
    pendingBannerTitle: AppStrings.successVoteCastEmergencyPendingBannerTitle,
    pendingBannerBody: AppStrings.successVoteCastEmergencyPendingBannerBody,
    agreedTitle: AppStrings.successVoteCastEmergencyAgreedTitle,
    agreedBody: AppStrings.successVoteCastEmergencyAgreedBody,
    disagreedTitle: AppStrings.successVoteCastEmergencyDisagreedTitle,
    disagreedBody: AppStrings.successVoteCastEmergencyDisagreedBody,
    deadlineLabel: AppStrings.successVoteCastDeadlineLabel,
    statGoalLabel: AppStrings.successVoteCastStatGoal,
    statMembersLabel: AppStrings.successVoteCastStatMembers,
    totalRaisedLabel: AppStrings.successVoteCastTotalRaised,
    memberVotesLabel: AppStrings.successVoteCastMemberVotesLabel,
    thumbsUpLabel: AppStrings.successVoteCastThumbsUp,
    thumbsDownLabel: AppStrings.successVoteCastThumbsDown,
    notVotedLabel: AppStrings.successVoteCastNotYetVotedLabel,
    voteQuestion: AppStrings.successVoteCastEmergencyVoteQuestion,
    voteYesLabel: AppStrings.successVoteCastEmergencyVoteYes,
    voteNoLabel: AppStrings.successVoteCastEmergencyVoteNo,
  );

  static const SuccessVoteCastCopy _emergencyCoLeader = SuccessVoteCastCopy(
    pendingBannerTitle: AppStrings.successVoteCastEmergencyPendingBannerTitle,
    pendingBannerBody: AppStrings.successVoteCastEmergencyCoLeaderPendingBannerBody,
    agreedTitle: AppStrings.successVoteCastEmergencyAgreedTitle,
    agreedBody: AppStrings.successVoteCastEmergencyAgreedBody,
    disagreedTitle: AppStrings.successVoteCastEmergencyDisagreedTitle,
    disagreedBody: AppStrings.successVoteCastEmergencyDisagreedBody,
    deadlineLabel: AppStrings.successVoteCastDeadlineLabel,
    statGoalLabel: AppStrings.successVoteCastStatGoal,
    statMembersLabel: AppStrings.successVoteCastStatMembers,
    totalRaisedLabel: AppStrings.successVoteCastTotalRaised,
    memberVotesLabel: AppStrings.successVoteCastMemberVotesLabel,
    thumbsUpLabel: AppStrings.successVoteCastThumbsUp,
    thumbsDownLabel: AppStrings.successVoteCastThumbsDown,
    notVotedLabel: AppStrings.successVoteCastNotYetVotedLabel,
    voteQuestion: AppStrings.successVoteCastEmergencyVoteQuestion,
    voteYesLabel: AppStrings.successVoteCastEmergencyVoteYes,
    voteNoLabel: AppStrings.successVoteCastEmergencyVoteNo,
  );

  static const SuccessVoteCastCopy _investmentStopContributions = SuccessVoteCastCopy(
    pendingBannerTitle: AppStrings.successVoteCastInvestmentPendingBannerTitle,
    pendingBannerBody: AppStrings.successVoteCastInvestmentPendingBannerBody,
    agreedTitle: AppStrings.successVoteCastInvestmentAgreedTitle,
    agreedBody: AppStrings.successVoteCastInvestmentAgreedBody,
    disagreedTitle: AppStrings.successVoteCastInvestmentDisagreedTitle,
    disagreedBody: AppStrings.successVoteCastInvestmentDisagreedBody,
    deadlineLabel: AppStrings.successVoteCastDeadlineLabel,
    statGoalLabel: AppStrings.successVoteCastStatGoal,
    statMembersLabel: AppStrings.successVoteCastStatMembers,
    totalRaisedLabel: AppStrings.successVoteCastTotalRaised,
    memberVotesLabel: AppStrings.successVoteCastMemberVotesLabel,
    thumbsUpLabel: AppStrings.successVoteCastThumbsUp,
    thumbsDownLabel: AppStrings.successVoteCastThumbsDown,
    notVotedLabel: AppStrings.successVoteCastNotYetVotedLabel,
    voteQuestion: AppStrings.successVoteCastInvestmentVoteQuestion,
    voteYesLabel: AppStrings.successVoteCastInvestmentVoteYes,
    voteNoLabel: AppStrings.successVoteCastInvestmentVoteNo,
  );

  static const SuccessVoteCastCopy _investmentMarkSuccessful = SuccessVoteCastCopy(
    pendingBannerTitle:
        AppStrings.successVoteCastInvestmentMarkSuccessfulPendingBannerTitle,
    pendingBannerBody:
        AppStrings.successVoteCastInvestmentMarkSuccessfulPendingBannerBody,
    agreedTitle: AppStrings.successVoteCastInvestmentMarkSuccessfulAgreedTitle,
    agreedBody: AppStrings.successVoteCastInvestmentMarkSuccessfulAgreedBody,
    disagreedTitle:
        AppStrings.successVoteCastInvestmentMarkSuccessfulDisagreedTitle,
    disagreedBody:
        AppStrings.successVoteCastInvestmentMarkSuccessfulDisagreedBody,
    deadlineLabel: AppStrings.successVoteCastDeadlineLabel,
    statGoalLabel: AppStrings.successVoteCastInvestmentTotalInvested,
    statMembersLabel: AppStrings.successVoteCastStatMembers,
    totalRaisedLabel: AppStrings.successVoteCastInvestmentTotalDistributedInclRoi,
    memberVotesLabel: AppStrings.successVoteCastMemberVotesLabel,
    thumbsUpLabel: AppStrings.successVoteCastThumbsUp,
    thumbsDownLabel: AppStrings.successVoteCastThumbsDown,
    notVotedLabel: AppStrings.successVoteCastNotYetVotedLabel,
    voteQuestion: AppStrings.successVoteCastInvestmentMarkSuccessfulVoteQuestion,
    voteYesLabel: AppStrings.successVoteCastInvestmentMarkSuccessfulVoteYes,
    voteNoLabel: AppStrings.successVoteCastInvestmentMarkSuccessfulVoteNo,
  );
}
