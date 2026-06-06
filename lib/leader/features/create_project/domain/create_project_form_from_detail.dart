import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';

import 'create_project_form.dart';

/// Maps [ProjectDetailEntity] into wizard form state for edit project.
abstract final class CreateProjectFormFromDetail {
  CreateProjectFormFromDetail._();

  static CreateProjectForm map(ProjectDetailEntity project) {
    final category = _mapCategory(project.category);
    final flowType = switch (category) {
      NewProjectCategory.investment =>
        ProjectCreationFlowType.investmentOptionalRoi,
      _ => ProjectCreationFlowType.fundsBorrowing,
    };

    return CreateProjectForm(
      editingProjectId: project.id,
      amountDigits: _amountDigits(project.goalAmount),
      flowType: flowType,
      projectName: project.name,
      description: project.announcement,
      category: category,
      deadline: _parseDeadline(project.endsIn),
      visibility: project.joinApprovalRequired
          ? ProjectVisibility.private
          : ProjectVisibility.public,
      borrowingEnabled: project.borrowingEnabled,
      repaymentWindow: project.repaymentWindowDays > 0
          ? '${project.repaymentWindowDays}'
          : '',
      penalty: _formatPercentField(project.penaltyPercentage),
      roi: _formatPercentField(project.roiPercentage),
    );
  }

  static NewProjectCategory _mapCategory(ProjectCategory category) {
    return switch (category) {
      ProjectCategory.investment => NewProjectCategory.investment,
      ProjectCategory.emergency => NewProjectCategory.emergency,
      ProjectCategory.vacations => NewProjectCategory.vacation,
    };
  }

  static String _amountDigits(double goalAmount) {
    if (goalAmount <= 0) return '';
    return goalAmount.round().toString();
  }

  static DateTime? _parseDeadline(String endsIn) {
    if (endsIn.trim().isEmpty) return null;
    final parsed = DateTime.tryParse(endsIn);
    if (parsed == null) return null;
    final utc = parsed.toUtc();
    return DateTime(utc.year, utc.month, utc.day);
  }

  static String _formatPercentField(double? value) {
    if (value == null || value <= 0) return '';
    if (value == value.roundToDouble()) {
      return value.round().toString();
    }
    return value.toString();
  }
}
