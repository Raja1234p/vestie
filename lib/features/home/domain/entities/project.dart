import '../../../../core/constants/app_strings.dart';
import 'user_flow_on_open.dart';

export 'user_flow_on_open.dart';

enum ProjectCategory { vacations, emergency, investment }

enum ProjectStatus { ongoing, completed }

enum ProjectRelation { owned, joined }

class Project {
  final String id;
  final String name;
  final ProjectCategory category;
  final ProjectStatus status;
  final ProjectRelation relation;
  final double? goalAmount;
  final double? currentAmount;
  final String? endsIn;
  final String? description;
  final bool requestPending;
  /// Mock: member-only — which full-screen flow opens instead of project detail.
  final UserFlowOnOpen? userFlow;

  const Project({
    required this.id,
    required this.name,
    required this.category,
    required this.status,
    required this.relation,
    this.goalAmount,
    this.currentAmount,
    this.endsIn,
    this.description,
    this.requestPending = false,
    this.userFlow,
  });

  String get categoryLabel {
    switch (category) {
      case ProjectCategory.vacations:   return AppStrings.filterVacations;
      case ProjectCategory.emergency:   return AppStrings.filterEmergency;
      case ProjectCategory.investment:  return AppStrings.filterInvestments;
    }
  }

  String get statusLabel =>
      status == ProjectStatus.ongoing ? AppStrings.statusOnGoing : AppStrings.statusCompleted;

  double get progress =>
      (goalAmount != null && currentAmount != null && goalAmount! > 0)
          ? (currentAmount! / goalAmount!).clamp(0.0, 1.0)
          : 0.0;
}
