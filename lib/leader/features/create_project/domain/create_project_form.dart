import 'package:equatable/equatable.dart';

/// Sentinel: distinguishes "not passed to copyWith" from "explicitly set to null".
const Object _absent = Object();

enum ProjectVisibility { public, private }

/// Content category shown on Project Details (independent from [ProjectCreationFlowType]).
enum NewProjectCategory {
  vacation,
  emergency,
  investment,
}

extension NewProjectCategoryLabel on NewProjectCategory {
  String get label {
    switch (this) {
      case NewProjectCategory.vacation:
        return 'Vacation';
      case NewProjectCategory.emergency:
        return 'Emergency';
      case NewProjectCategory.investment:
        return 'Investment';
    }
  }
}

/// Matches the three end-to-end product flows:
/// Saving (auto-save settings) | Funds borrowing | Simple (review after details).
enum ProjectCreationFlowType {
  collaborativeSaving,
  fundsBorrowing,
  streamlined,
}

extension ProjectCreationFlowTypeLabel on ProjectCreationFlowType {
  String get shortLabel => switch (this) {
        ProjectCreationFlowType.collaborativeSaving => 'Saving',
        ProjectCreationFlowType.fundsBorrowing => 'Borrowing',
        ProjectCreationFlowType.streamlined => 'Simple',
      };
}

extension ProjectCreationFlowTypeRouting on ProjectCreationFlowType {
  int get wizardStepTotal => switch (this) {
        ProjectCreationFlowType.streamlined => 3,
        _ => 4,
      };

  bool get usesSavingSettings =>
      this == ProjectCreationFlowType.collaborativeSaving;

  bool get usesBorrowingSettings =>
      this == ProjectCreationFlowType.fundsBorrowing;
}

/// Immutable form state for the Create Project wizard.
class CreateProjectForm extends Equatable {
  // ── Step 0 – Amount ─────────────────────────────────────────────────────
  final String amountDigits;

  // ── Step 1 – Details ────────────────────────────────────────────────────
  final ProjectCreationFlowType flowType;
  final String projectName;
  final String description;
  final NewProjectCategory category;
  final DateTime? deadline;
  final ProjectVisibility visibility;

  // ── Collaborative saving path (Project Settings) ──────────────────────
  final bool autoSaveEnabled;

  // ── Funds borrowing path ────────────────────────────────────────────────
  final String roi;
  final bool borrowingEnabled;
  /// Repayment period in **whole months** (UX); not mapped 1:1 to API here.
  final String repaymentWindow;
  final String? repaymentWindowError;
  final String? roiError;

  // ── Validation errors (details) ─────────────────────────────────────────
  final String? nameError;
  final String? descError;
  final String? deadlineError;

  const CreateProjectForm({
    this.amountDigits = '',
    this.flowType = ProjectCreationFlowType.collaborativeSaving,
    this.projectName = '',
    this.description = '',
    this.category = NewProjectCategory.vacation,
    this.deadline,
    this.visibility = ProjectVisibility.public,
    this.autoSaveEnabled = false,
    this.roi = '',
    this.borrowingEnabled = true,
    this.repaymentWindow = '',
    this.repaymentWindowError,
    this.roiError,
    this.nameError,
    this.descError,
    this.deadlineError,
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

  CreateProjectForm copyWith({
    String? amountDigits,
    ProjectCreationFlowType? flowType,
    String? projectName,
    String? description,
    NewProjectCategory? category,
    Object? deadline = _absent,
    ProjectVisibility? visibility,
    bool? autoSaveEnabled,
    String? roi,
    bool? borrowingEnabled,
    String? repaymentWindow,
    Object? repaymentWindowError = _absent,
    Object? roiError = _absent,
    Object? nameError = _absent,
    Object? descError = _absent,
    Object? deadlineError = _absent,
  }) {
    return CreateProjectForm(
      amountDigits: amountDigits ?? this.amountDigits,
      flowType: flowType ?? this.flowType,
      projectName: projectName ?? this.projectName,
      description: description ?? this.description,
      category: category ?? this.category,
      deadline: identical(deadline, _absent) ? this.deadline : deadline as DateTime?,
      visibility: visibility ?? this.visibility,
      autoSaveEnabled: autoSaveEnabled ?? this.autoSaveEnabled,
      roi: roi ?? this.roi,
      borrowingEnabled: borrowingEnabled ?? this.borrowingEnabled,
      repaymentWindow: repaymentWindow ?? this.repaymentWindow,
      repaymentWindowError: identical(repaymentWindowError, _absent)
          ? this.repaymentWindowError
          : repaymentWindowError as String?,
      roiError: identical(roiError, _absent) ? this.roiError : roiError as String?,
      nameError: identical(nameError, _absent) ? this.nameError : nameError as String?,
      descError: identical(descError, _absent) ? this.descError : descError as String?,
      deadlineError: identical(deadlineError, _absent)
          ? this.deadlineError
          : deadlineError as String?,
    );
  }

  @override
  List<Object?> get props => [
        amountDigits,
        flowType,
        projectName,
        description,
        category,
        deadline,
        visibility,
        autoSaveEnabled,
        roi,
        borrowingEnabled,
        repaymentWindow,
        repaymentWindowError,
        roiError,
        nameError,
        descError,
        deadlineError,
      ];
}
