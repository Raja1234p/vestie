import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
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

  /// Returns custom icon asset for categories that use one.
  /// Vacations intentionally uses the shared beach material icon fallback.
  String? get iconAsset {
    switch (this) {
      case ProjectCategory.vacations:
        return null;
      case ProjectCategory.emergency:
        return AppAssets.iconEmergencyFund;
      case ProjectCategory.investment:
        return AppAssets.iconInvestmentFund;
    }
  }

  bool get isInvestment => this == ProjectCategory.investment;

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

