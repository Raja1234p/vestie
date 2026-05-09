import 'package:intl/intl.dart';

/// Vacation vs Emergency variant for member-facing fund UX (mock / local routing).
enum CreateProjectFundKind {
  vacation,
  emergency,
}

extension CreateProjectFundKindUi on CreateProjectFundKind {
  /// Suggested hero filenames under `Desktop/images`.
  String get suggestedHeroFilename => switch (this) {
        CreateProjectFundKind.vacation => 'vacation_hero.png',
        CreateProjectFundKind.emergency => 'emergency_hero.png',
      };

  double get mockRaisedVsGoalFraction => switch (this) {
        CreateProjectFundKind.vacation => 0.35,
        CreateProjectFundKind.emergency => 0.42,
      };
}

/// Payload passed via [RouteSettings.extra] across setup → summary → detail → contributions → status.
class CreateProjectFundDraft {
  final CreateProjectFundKind kind;
  final String projectName;
  final double goalAmountUsd;
  final DateTime startDate;
  final DateTime endDate;
  final String description;

  const CreateProjectFundDraft({
    required this.kind,
    required this.projectName,
    required this.goalAmountUsd,
    required this.startDate,
    required this.endDate,
    required this.description,
  });

  String get formattedGoalUsd {
    final n = NumberFormat('#,##0.00', 'en_US');
    return '\$${n.format(goalAmountUsd)} USD';
  }

  String formatDate(DateTime d) =>
      DateFormat('d MMMM y', 'en_US').format(d);

  int get mockPercentTowardGoal =>
      (mockRaisedVsGoalFraction * 100).clamp(1, 99).round();

  double get mockRaisedUsd => goalAmountUsd * mockRaisedVsGoalFraction;

  double get mockRaisedVsGoalFraction => kind.mockRaisedVsGoalFraction;
}
