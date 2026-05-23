import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'project.dart';

/// Shared category helpers to keep route/widget/copy layers decoupled from
/// repeated enum switch blocks.
extension ProjectCategoryX on ProjectCategory {
  String get label {
    switch (this) {
      case ProjectCategory.vacations:
        return AppStrings.filterVacations;
      case ProjectCategory.emergency:
        return AppStrings.filterEmergency;
      case ProjectCategory.investment:
        return AppStrings.filterInvestments;
    }
  }

  /// Category chip icon on home cards and project detail.
  String? get iconAsset {
    switch (this) {
      case ProjectCategory.vacations:
        return AppAssets.iconVacationUmbrella;
      case ProjectCategory.emergency:
        return AppAssets.iconEmergencyFund;
      case ProjectCategory.investment:
        return AppAssets.iconInvestmentFund;
    }
  }

  bool get isInvestment => this == ProjectCategory.investment;

  /// Co-leader role is supported on Vacation and Emergency groups only.
  bool get supportsCoLeader =>
      this == ProjectCategory.vacations ||
      this == ProjectCategory.emergency;

  /// Label used in project detail chips/content.
  /// Kept explicit to preserve current UI copy exactly.
  String get detailLabel {
    switch (this) {
      case ProjectCategory.vacations:
        return 'Vacations';
      case ProjectCategory.emergency:
        return 'Emergency';
      case ProjectCategory.investment:
        return 'Investment';
    }
  }
}

