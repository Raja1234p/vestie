import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';

import 'success_vote_outcome_role.dart';
import 'success_vote_outcome_variant.dart';

/// Role-specific strings for the shared success-vote outcome layout.
class SuccessVoteOutcomeCopy {
  final String approvedTitle;
  final String approvedSubtitle;
  final String rejectedTitle;
  final String rejectedSubtitle;
  final String amountCaptionApproved;
  final String amountCaptionRejected;
  final String primaryButtonApproved;
  final String primaryButtonRejected;
  final String voteSummaryLabel;
  final String agreedLabel;
  final String disagreedLabel;

  const SuccessVoteOutcomeCopy({
    required this.approvedTitle,
    required this.approvedSubtitle,
    required this.rejectedTitle,
    required this.rejectedSubtitle,
    required this.amountCaptionApproved,
    required this.amountCaptionRejected,
    required this.primaryButtonApproved,
    required this.primaryButtonRejected,
    required this.voteSummaryLabel,
    required this.agreedLabel,
    required this.disagreedLabel,
  });

  String titleFor(bool isApproved) =>
      isApproved ? approvedTitle : rejectedTitle;

  String subtitleFor(bool isApproved) =>
      isApproved ? approvedSubtitle : rejectedSubtitle;

  String amountCaptionFor(bool isApproved) =>
      isApproved ? amountCaptionApproved : amountCaptionRejected;

  String primaryButtonFor(bool isApproved) =>
      isApproved ? primaryButtonApproved : primaryButtonRejected;

  static SuccessVoteOutcomeCopy forRole(
    SuccessVoteOutcomeRole role, {
    ProjectCategory? category,
    SuccessVoteOutcomeVariant variant = SuccessVoteOutcomeVariant.successVote,
  }) {
    if (category == ProjectCategory.investment &&
        variant == SuccessVoteOutcomeVariant.stopContributionsRejected) {
      return switch (role) {
        SuccessVoteOutcomeRole.groupLeader =>
          _investmentStopContributionsRejectedLeader,
        SuccessVoteOutcomeRole.coLeader ||
        SuccessVoteOutcomeRole.member =>
          _investmentStopContributionsRejectedMember,
      };
    }

    if (role == SuccessVoteOutcomeRole.groupLeader) {
      return switch (category) {
        ProjectCategory.investment => _investmentGroupLeader,
        ProjectCategory.emergency => _emergencyGroupLeader,
        ProjectCategory.vacations => _vacationGroupLeader,
        _ => _vacationGroupLeader,
      };
    }

    if (role == SuccessVoteOutcomeRole.coLeader) {
      return switch (category) {
        ProjectCategory.vacations => _vacationCoLeaderAndMember,
        ProjectCategory.emergency => _emergencyCoLeaderApproved,
        ProjectCategory.investment => _investmentCoLeaderAndMember,
        _ => _vacationCoLeaderAndMember,
      };
    }

    if (role == SuccessVoteOutcomeRole.member) {
      return switch (category) {
        ProjectCategory.vacations => _vacationCoLeaderAndMember,
        ProjectCategory.emergency => _emergencyCoLeaderAndMember,
        ProjectCategory.investment => _investmentCoLeaderAndMember,
        _ => _member,
      };
    }

    return switch (role) {
      SuccessVoteOutcomeRole.coLeader => _coLeader,
      SuccessVoteOutcomeRole.member => _member,
      SuccessVoteOutcomeRole.groupLeader => _vacationGroupLeader,
    };
  }

  static const SuccessVoteOutcomeCopy _vacationGroupLeader =
      SuccessVoteOutcomeCopy(
    approvedTitle: AppStrings.successVoteOutcomeLeaderApprovedTitle,
    approvedSubtitle: AppStrings.successVoteOutcomeLeaderApprovedSubtitle,
    rejectedTitle: AppStrings.successVoteOutcomeLeaderRejectedTitle,
    rejectedSubtitle: AppStrings.successVoteOutcomeLeaderRejectedSubtitle,
    amountCaptionApproved:
        AppStrings.successVoteOutcomeVacationLeaderAmountApprovedCaption,
    amountCaptionRejected:
        AppStrings.successVoteOutcomeLeaderAmountRejectedCaption,
    primaryButtonApproved: AppStrings.btnBackToHome,
    primaryButtonRejected: AppStrings.btnBackToHome,
    voteSummaryLabel: AppStrings.projectVoteSummaryLabel,
    agreedLabel: AppStrings.projectVoteAgreedLabel,
    disagreedLabel: AppStrings.projectVoteDisagreedLabel,
  );

  static const SuccessVoteOutcomeCopy _emergencyGroupLeader =
      SuccessVoteOutcomeCopy(
    approvedTitle: AppStrings.successVoteOutcomeLeaderApprovedTitle,
    approvedSubtitle: AppStrings.successVoteOutcomeLeaderApprovedSubtitle,
    rejectedTitle: AppStrings.successVoteOutcomeLeaderRejectedTitle,
    rejectedSubtitle: AppStrings.successVoteOutcomeLeaderRejectedSubtitle,
    amountCaptionApproved:
        AppStrings.successVoteOutcomeEmergencyLeaderAmountApprovedCaption,
    amountCaptionRejected:
        AppStrings.successVoteOutcomeLeaderAmountRejectedCaption,
    primaryButtonApproved: AppStrings.btnBackToHome,
    primaryButtonRejected: AppStrings.btnBackToHome,
    voteSummaryLabel: AppStrings.projectVoteSummaryLabel,
    agreedLabel: AppStrings.projectVoteAgreedLabel,
    disagreedLabel: AppStrings.projectVoteDisagreedLabel,
  );

  static const SuccessVoteOutcomeCopy _investmentGroupLeader =
      SuccessVoteOutcomeCopy(
    approvedTitle: AppStrings.successVoteOutcomeInvestmentLeaderApprovedTitle,
    approvedSubtitle:
        AppStrings.successVoteOutcomeInvestmentLeaderApprovedSubtitle,
    rejectedTitle: AppStrings.successVoteOutcomeLeaderRejectedTitle,
    rejectedSubtitle: AppStrings.successVoteOutcomeLeaderRejectedSubtitle,
    amountCaptionApproved:
        AppStrings.successVoteOutcomeInvestmentLeaderAmountApprovedCaption,
    amountCaptionRejected:
        AppStrings.successVoteOutcomeLeaderAmountRejectedCaption,
    primaryButtonApproved: AppStrings.btnBackToHome,
    primaryButtonRejected: AppStrings.btnBackToHome,
    voteSummaryLabel: AppStrings.projectVoteSummaryLabel,
    agreedLabel: AppStrings.projectVoteAgreedLabel,
    disagreedLabel: AppStrings.projectVoteDisagreedLabel,
  );

  static const SuccessVoteOutcomeCopy _investmentStopContributionsRejectedLeader =
      SuccessVoteOutcomeCopy(
    approvedTitle: AppStrings.successVoteOutcomeInvestmentLeaderApprovedTitle,
    approvedSubtitle:
        AppStrings.successVoteOutcomeInvestmentLeaderApprovedSubtitle,
    rejectedTitle:
        AppStrings.successVoteOutcomeInvestmentStopContributionsRejectedTitle,
    rejectedSubtitle:
        AppStrings.successVoteOutcomeInvestmentStopContributionsRejectedSubtitle,
    amountCaptionApproved:
        AppStrings.successVoteOutcomeInvestmentLeaderAmountApprovedCaption,
    amountCaptionRejected: AppStrings
        .successVoteOutcomeInvestmentStopContributionsRejectedAmountCaption,
    primaryButtonApproved: AppStrings.btnBackToHome,
    primaryButtonRejected: AppStrings.btnBackToHome,
    voteSummaryLabel: AppStrings.projectVoteSummaryLabel,
    agreedLabel: AppStrings.projectVoteAgreedLabel,
    disagreedLabel: AppStrings.projectVoteDisagreedLabel,
  );

  static const SuccessVoteOutcomeCopy _investmentStopContributionsRejectedMember =
      SuccessVoteOutcomeCopy(
    approvedTitle:
        AppStrings.successVoteOutcomeInvestmentCoLeaderMemberApprovedTitle,
    approvedSubtitle:
        AppStrings.successVoteOutcomeInvestmentCoLeaderMemberApprovedSubtitle,
    rejectedTitle:
        AppStrings.successVoteOutcomeInvestmentStopContributionsRejectedTitle,
    rejectedSubtitle: AppStrings
        .successVoteOutcomeInvestmentMemberStopContributionsRejectedSubtitle,
    amountCaptionApproved: AppStrings
        .successVoteOutcomeInvestmentCoLeaderMemberAmountApprovedCaption,
    amountCaptionRejected: AppStrings
        .successVoteOutcomeInvestmentMemberStopContributionsRejectedAmountCaption,
    primaryButtonApproved: AppStrings.btnBackToHome,
    primaryButtonRejected: AppStrings.btnBackToHome,
    voteSummaryLabel: AppStrings.projectVoteSummaryLabel,
    agreedLabel: AppStrings.projectVoteAgreedLabel,
    disagreedLabel: AppStrings.projectVoteDisagreedLabel,
  );

  /// Vacation — co-leader and member share the same copy.
  static const SuccessVoteOutcomeCopy _vacationCoLeaderAndMember =
      SuccessVoteOutcomeCopy(
    approvedTitle: AppStrings.successVoteOutcomeCoLeaderApprovedTitle,
    approvedSubtitle: AppStrings.successVoteOutcomeCoLeaderApprovedSubtitle,
    rejectedTitle: AppStrings.successVoteOutcomeCoLeaderRejectedTitle,
    rejectedSubtitle: AppStrings.successVoteOutcomeCoLeaderRejectedSubtitle,
    amountCaptionApproved:
        AppStrings.successVoteOutcomeCoLeaderAmountApprovedCaption,
    amountCaptionRejected:
        AppStrings.successVoteOutcomeVacationCoLeaderMemberAmountRejectedCaption,
    primaryButtonApproved: AppStrings.btnBackToHome,
    primaryButtonRejected: AppStrings.btnBackToHome,
    voteSummaryLabel: AppStrings.projectVoteSummaryLabel,
    agreedLabel: AppStrings.projectVoteAgreedLabel,
    disagreedLabel: AppStrings.projectVoteDisagreedLabel,
  );

  /// Emergency — co-leader approved (Figma).
  static const SuccessVoteOutcomeCopy _emergencyCoLeaderApproved =
      SuccessVoteOutcomeCopy(
    approvedTitle:
        AppStrings.successVoteOutcomeEmergencyCoLeaderMemberApprovedTitle,
    approvedSubtitle:
        AppStrings.successVoteOutcomeEmergencyCoLeaderMemberApprovedSubtitle,
    rejectedTitle: AppStrings.successVoteOutcomeCoLeaderRejectedTitle,
    rejectedSubtitle: AppStrings.successVoteOutcomeCoLeaderRejectedSubtitle,
    amountCaptionApproved: AppStrings
        .successVoteOutcomeEmergencyCoLeaderMemberAmountApprovedCaption,
    amountCaptionRejected:
        AppStrings.successVoteOutcomeVacationCoLeaderMemberAmountRejectedCaption,
    primaryButtonApproved: AppStrings.successVoteOutcomeCoLeaderBtnApproved,
    primaryButtonRejected: AppStrings.btnBackToHome,
    voteSummaryLabel: AppStrings.projectVoteSummaryLabel,
    agreedLabel: AppStrings.projectVoteAgreedLabel,
    disagreedLabel: AppStrings.projectVoteDisagreedLabel,
  );

  /// Emergency — member approved (Figma).
  static const SuccessVoteOutcomeCopy _emergencyCoLeaderAndMember =
      SuccessVoteOutcomeCopy(
    approvedTitle:
        AppStrings.successVoteOutcomeEmergencyCoLeaderMemberApprovedTitle,
    approvedSubtitle:
        AppStrings.successVoteOutcomeEmergencyCoLeaderMemberApprovedSubtitle,
    rejectedTitle: AppStrings.successVoteOutcomeCoLeaderRejectedTitle,
    rejectedSubtitle: AppStrings.successVoteOutcomeCoLeaderRejectedSubtitle,
    amountCaptionApproved: AppStrings
        .successVoteOutcomeEmergencyCoLeaderMemberAmountApprovedCaption,
    amountCaptionRejected:
        AppStrings.successVoteOutcomeVacationCoLeaderMemberAmountRejectedCaption,
    primaryButtonApproved: AppStrings.successVoteOutcomeCoLeaderBtnApproved,
    primaryButtonRejected: AppStrings.btnBackToHome,
    voteSummaryLabel: AppStrings.projectVoteSummaryLabel,
    agreedLabel: AppStrings.projectVoteAgreedLabel,
    disagreedLabel: AppStrings.projectVoteDisagreedLabel,
  );

  /// Investment — co-leader and member share the same approved copy.
  static const SuccessVoteOutcomeCopy _investmentCoLeaderAndMember =
      SuccessVoteOutcomeCopy(
    approvedTitle:
        AppStrings.successVoteOutcomeInvestmentCoLeaderMemberApprovedTitle,
    approvedSubtitle:
        AppStrings.successVoteOutcomeInvestmentCoLeaderMemberApprovedSubtitle,
    rejectedTitle: AppStrings.projectVoteNotApprovedTitle,
    rejectedSubtitle: AppStrings.projectVoteNotApprovedSubtitle,
    amountCaptionApproved: AppStrings
        .successVoteOutcomeInvestmentCoLeaderMemberAmountApprovedCaption,
    amountCaptionRejected:
        AppStrings.successVoteOutcomeVacationCoLeaderMemberAmountRejectedCaption,
    primaryButtonApproved: AppStrings.btnBackToHome,
    primaryButtonRejected: AppStrings.btnBackToHome,
    voteSummaryLabel: AppStrings.projectVoteSummaryLabel,
    agreedLabel: AppStrings.projectVoteAgreedLabel,
    disagreedLabel: AppStrings.projectVoteDisagreedLabel,
  );

  static const SuccessVoteOutcomeCopy _coLeader = _vacationCoLeaderAndMember;

  static const SuccessVoteOutcomeCopy _member = SuccessVoteOutcomeCopy(
    approvedTitle: AppStrings.projectVoteApprovedTitle,
    approvedSubtitle: AppStrings.projectVoteApprovedSubtitle,
    rejectedTitle: AppStrings.projectVoteNotApprovedTitle,
    rejectedSubtitle: AppStrings.projectVoteNotApprovedSubtitle,
    amountCaptionApproved: AppStrings.successVoteOutcomeCoLeaderAmountApprovedCaption,
    amountCaptionRejected:
        AppStrings.successVoteOutcomeVacationCoLeaderMemberAmountRejectedCaption,
    primaryButtonApproved: AppStrings.btnBackToHome,
    primaryButtonRejected: AppStrings.btnBackToHome,
    voteSummaryLabel: AppStrings.projectVoteSummaryLabel,
    agreedLabel: AppStrings.projectVoteAgreedLabel,
    disagreedLabel: AppStrings.projectVoteDisagreedLabel,
  );
}
