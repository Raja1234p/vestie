import 'package:vestie/leader/features/create_project/domain/create_project_form.dart';

class CreateProjectRequestModel {
  final String name;
  final String description;
  final String type;
  final String visibility;
  final double targetAmount;
  final String? endsAtUtc;
  final bool borrowingEnabled;
  final bool joinApprovalRequired;
  final double? roiPercentage;
  final int repaymentWindowDays;
  final double? penaltyPercentage;

  const CreateProjectRequestModel({
    required this.name,
    required this.description,
    required this.type,
    required this.visibility,
    required this.targetAmount,
    this.endsAtUtc,
    required this.borrowingEnabled,
    required this.joinApprovalRequired,
    required this.roiPercentage,
    required this.repaymentWindowDays,
    required this.penaltyPercentage,
  });

  factory CreateProjectRequestModel.fromForm(CreateProjectForm form) {
    final ends = _endsAtUtcIso(form.deadline);

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

    double? parseOptionalDouble(String s) {
      final t = s.trim();
      if (t.isEmpty) return null;
      return double.tryParse(t);
    }

    final investmentRoiOnly =
        form.flowType == ProjectCreationFlowType.investmentOptionalRoi;

    return CreateProjectRequestModel(
      name: form.projectName.trim(),
      description: form.description.trim(),
      type: mapType(form.category),
      visibility: mapVisibility(form.visibility),
      targetAmount: form.displayAmount,
      endsAtUtc: ends,
      borrowingEnabled: investmentRoiOnly ? false : form.borrowingEnabled,
      joinApprovalRequired: form.visibility != ProjectVisibility.public,
      roiPercentage: investmentRoiOnly
          ? parseOptionalDouble(form.roi.replaceAll('%', ''))
          : null,
      repaymentWindowDays: investmentRoiOnly
          ? 30
          : (form.borrowingEnabled ? parseInt(form.repaymentWindow) : 0),
      penaltyPercentage: investmentRoiOnly
          ? null
          : (form.borrowingEnabled
                ? parseDouble(form.penalty.replaceAll('%', ''))
                : null),
    );
  }

  /// Sends the calendar day as UTC end-of-day so the API date matches the picker.
  static String? _endsAtUtcIso(DateTime? deadline) {
    if (deadline == null) return null;
    final d = DateTime(deadline.year, deadline.month, deadline.day);
    return DateTime.utc(
      d.year,
      d.month,
      d.day,
      23,
      59,
      59,
      999,
    ).toIso8601String();
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'type': type,
    'visibility': visibility,
    'targetAmount': targetAmount,
    'endsAtUtc': endsAtUtc,
    'borrowingEnabled': borrowingEnabled,
    'joinApprovalRequired': joinApprovalRequired,
    'roiPercentage': roiPercentage,
    'repaymentWindowDays': repaymentWindowDays,
    'penaltyPercentage': penaltyPercentage,
  };
}
