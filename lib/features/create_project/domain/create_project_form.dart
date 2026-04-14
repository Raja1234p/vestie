import 'package:equatable/equatable.dart';

/// Sentinel: distinguishes "not passed to copyWith" from "explicitly set to null".
/// Used for nullable fields (errors, deadline) so they can be cleared via copyWith.
const Object _absent = Object();

enum ProjectVisibility { public, private }

enum NewProjectCategory { vacation, emergency, investment, other }

extension NewProjectCategoryLabel on NewProjectCategory {
  String get label {
    switch (this) {
      case NewProjectCategory.vacation:   return 'Vacation';
      case NewProjectCategory.emergency:  return 'Emergency';
      case NewProjectCategory.investment: return 'Investment';
      case NewProjectCategory.other:      return 'Other';
    }
  }
}

/// Immutable form state for the entire Create Project wizard.
/// Validation errors are part of the state (null = no error).
class CreateProjectForm extends Equatable {
  // ── Step 0 – Amount ────────────────────────────────────────────────────
  final String amountDigits; // raw digits, e.g. "24000" → $240.00

  // ── Step 1 – Details ──────────────────────────────────────────────────
  final String projectName;
  final String description;
  final NewProjectCategory category;
  final DateTime? deadline;
  final ProjectVisibility visibility;

  // ── Step 2 – Borrowing ────────────────────────────────────────────────
  final String roi;
  final bool borrowingEnabled;
  final String borrowLimit;
  final String repaymentWindow;
  final String penalty;

  // ── Validation errors (null = no error) ──────────────────────────────
  final String? nameError;
  final String? descError;
  final String? deadlineError;
  final String? borrowLimitError;
  final String? repaymentWindowError;
  final String? penaltyError;

  const CreateProjectForm({
    this.amountDigits    = '',
    this.projectName     = '',
    this.description     = '',
    this.category        = NewProjectCategory.vacation,
    this.deadline,
    this.visibility      = ProjectVisibility.public,
    this.roi             = '',
    this.borrowingEnabled = false,
    this.borrowLimit     = '',
    this.repaymentWindow = '',
    this.penalty         = '',
    this.nameError,
    this.descError,
    this.deadlineError,
    this.borrowLimitError,
    this.repaymentWindowError,
    this.penaltyError,
  });

  double get displayAmount =>
      amountDigits.isEmpty ? 0.0 : (int.tryParse(amountDigits)?.toDouble() ?? 0.0);

  String get formattedAmount {
    final intPart = displayAmount.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return '\$$intPart.00';
  }

  String get deadlineFormatted {
    if (deadline == null) return '';
    return '${deadline!.month.toString().padLeft(2, '0')}/'
        '${deadline!.day.toString().padLeft(2, '0')}/'
        '${deadline!.year}';
  }

  /// Supports clearing nullable fields (errors, deadline) by passing explicit null.
  /// Use the [_absent] sentinel as the default so "not provided" ≠ "set to null".
  CreateProjectForm copyWith({
    String? amountDigits,
    String? projectName,
    String? description,
    NewProjectCategory? category,
    Object? deadline          = _absent,
    ProjectVisibility? visibility,
    String? roi,
    bool? borrowingEnabled,
    String? borrowLimit,
    String? repaymentWindow,
    String? penalty,
    Object? nameError             = _absent,
    Object? descError             = _absent,
    Object? deadlineError         = _absent,
    Object? borrowLimitError      = _absent,
    Object? repaymentWindowError  = _absent,
    Object? penaltyError          = _absent,
  }) {
    return CreateProjectForm(
      amountDigits:    amountDigits    ?? this.amountDigits,
      projectName:     projectName     ?? this.projectName,
      description:     description     ?? this.description,
      category:        category        ?? this.category,
      deadline:        identical(deadline, _absent)         ? this.deadline         : deadline as DateTime?,
      visibility:      visibility      ?? this.visibility,
      roi:             roi             ?? this.roi,
      borrowingEnabled: borrowingEnabled ?? this.borrowingEnabled,
      borrowLimit:     borrowLimit     ?? this.borrowLimit,
      repaymentWindow: repaymentWindow ?? this.repaymentWindow,
      penalty:         penalty         ?? this.penalty,
      nameError:            identical(nameError, _absent)            ? this.nameError            : nameError as String?,
      descError:            identical(descError, _absent)            ? this.descError            : descError as String?,
      deadlineError:        identical(deadlineError, _absent)        ? this.deadlineError        : deadlineError as String?,
      borrowLimitError:     identical(borrowLimitError, _absent)     ? this.borrowLimitError     : borrowLimitError as String?,
      repaymentWindowError: identical(repaymentWindowError, _absent) ? this.repaymentWindowError : repaymentWindowError as String?,
      penaltyError:         identical(penaltyError, _absent)         ? this.penaltyError         : penaltyError as String?,
    );
  }

  @override
  List<Object?> get props => [
    amountDigits, projectName, description, category, deadline,
    visibility, roi, borrowingEnabled, borrowLimit, repaymentWindow, penalty,
    nameError, descError, deadlineError, borrowLimitError, repaymentWindowError, penaltyError,
  ];
}
