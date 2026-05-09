import 'package:vestie/leader/features/create_project/domain/create_project_form.dart';

class CreateProjectRequestModel {
  final String name;
  final String description;
  final String type;
  final String visibility;
  final double targetAmount;
  final int maxMembers;
  final String endsAtUtc;
  final String contributionDeadlineUtc;
  final bool borrowingEnabled;
  final double suggestedContributionAmount;
  final bool joinApprovalRequired;
  final double roiPercentage;
  final int repaymentWindowDays;
  final int repaymentGraceDays;
  final double penaltyPercentage;
  final double minimumContributionAmount;
  final bool contributionsAreNonRefundable;

  const CreateProjectRequestModel({
    required this.name,
    required this.description,
    required this.type,
    required this.visibility,
    required this.targetAmount,
    required this.maxMembers,
    required this.endsAtUtc,
    required this.contributionDeadlineUtc,
    required this.borrowingEnabled,
    required this.suggestedContributionAmount,
    required this.joinApprovalRequired,
    required this.roiPercentage,
    required this.repaymentWindowDays,
    required this.repaymentGraceDays,
    required this.penaltyPercentage,
    required this.minimumContributionAmount,
    required this.contributionsAreNonRefundable,
  });

  factory CreateProjectRequestModel.fromForm(CreateProjectForm form) {
    final ends = (form.deadline ?? DateTime.now().add(const Duration(days: 30)))
        .toUtc()
        .toIso8601String();

    String mapType(NewProjectCategory c) => switch (c) {
          NewProjectCategory.vacation => 'Vacation',
          NewProjectCategory.emergency => 'Emergency',
          NewProjectCategory.investment => 'Investment',
        };

    String mapVisibility(ProjectVisibility v) => switch (v) {
          ProjectVisibility.public => 'Public',
          ProjectVisibility.private => 'Private',
        };

    double parseDouble(String s) => double.tryParse(s.trim()) ?? 0.0;
    int parseInt(String s) => int.tryParse(s.trim()) ?? 0;

    // Backend requires fields not present in UI today. We send safe defaults
    // until those inputs are added to the wizard.
    return CreateProjectRequestModel(
      name: form.projectName.trim(),
      description: form.description.trim(),
      type: mapType(form.category),
      visibility: mapVisibility(form.visibility),
      targetAmount: form.displayAmount,
      maxMembers: 20,
      endsAtUtc: ends,
      contributionDeadlineUtc: ends,
      borrowingEnabled: form.borrowingEnabled,
      suggestedContributionAmount: 0,
      joinApprovalRequired: true,
      roiPercentage:
          form.borrowingEnabled ? parseDouble(form.roi) : 0.0,
      repaymentWindowDays: form.borrowingEnabled
          ? parseInt(form.repaymentWindow) * 30
          : 0,
      repaymentGraceDays: 0,
      penaltyPercentage: 0,
      minimumContributionAmount: 0.0,
      contributionsAreNonRefundable: false,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'type': type,
        'visibility': visibility,
        'targetAmount': targetAmount,
        'maxMembers': maxMembers,
        'endsAtUtc': endsAtUtc,
        'contributionDeadlineUtc': contributionDeadlineUtc,
        'borrowingEnabled': borrowingEnabled,
        'suggestedContributionAmount': suggestedContributionAmount,
        'joinApprovalRequired': joinApprovalRequired,
        'roiPercentage': roiPercentage,
        'repaymentWindowDays': repaymentWindowDays,
        'repaymentGraceDays': repaymentGraceDays,
        'penaltyPercentage': penaltyPercentage,
        'minimumContributionAmount': minimumContributionAmount,
        'contributionsAreNonRefundable': contributionsAreNonRefundable,
      };
}

