import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/validation_utils.dart';
import '../../domain/create_project_form.dart';

/// Manages the entire Create Project wizard state.
/// Each setter clears its own error. Validation emits errors into state.
class CreateProjectCubit extends Cubit<CreateProjectForm> {
  CreateProjectCubit() : super(const CreateProjectForm());

  // ── Step 0 – Amount (max 9,999,999 = 7 digits, no leading zero) ─────────
  void appendAmountDigit(String d) {
    if (state.amountDigits.isEmpty && d == '0') return;
    if (state.amountDigits.length >= 7) return;
    emit(state.copyWith(amountDigits: state.amountDigits + d));
  }

  void removeAmountDigit() {
    if (state.amountDigits.isEmpty) return;
    emit(state.copyWith(
        amountDigits: state.amountDigits.substring(0, state.amountDigits.length - 1)));
  }

  // ── Step 1 – Details (each setter clears its own validation error) ───────
  void setProjectName(String v) =>
      emit(state.copyWith(projectName: v, nameError: null));

  void setDescription(String v) =>
      emit(state.copyWith(description: v, descError: null));

  void setCategory(NewProjectCategory c) => emit(state.copyWith(category: c));

  void setDeadline(DateTime d) =>
      emit(state.copyWith(deadline: d, deadlineError: null));

  void setVisibility(ProjectVisibility v) => emit(state.copyWith(visibility: v));

  // ── Step 2 – Borrowing (each setter clears its own validation error) ─────
  void setRoi(String v)             => emit(state.copyWith(roi: v));
  void toggleBorrowing(bool v)      => emit(state.copyWith(borrowingEnabled: v));
  void setBorrowLimit(String v)     => emit(state.copyWith(borrowLimit: v, borrowLimitError: null));
  void setRepaymentWindow(String v) => emit(state.copyWith(repaymentWindow: v, repaymentWindowError: null));
  void setPenalty(String v)         => emit(state.copyWith(penalty: v, penaltyError: null));

  // ── Validation ───────────────────────────────────────────────────────────

  /// Validates Step 1 fields. Emits error state. Returns true when all pass.
  bool validateDetails() {
    final nameErr     = ValidationUtils.validateProjectName(state.projectName);
    final descErr     = ValidationUtils.validateProjectDescription(state.description);
    final deadlineErr = ValidationUtils.validateProjectDeadline(state.deadline);
    emit(state.copyWith(
      nameError:     nameErr,
      descError:     descErr,
      deadlineError: deadlineErr,
    ));
    return nameErr == null && descErr == null && deadlineErr == null;
  }

  /// Validates Step 2 borrowing fields (only when borrowing is enabled).
  /// Returns true when all pass (or borrowing is disabled).
  bool validateBorrowing() {
    if (!state.borrowingEnabled) return true;
    final limitErr   = ValidationUtils.validateBorrowLimit(state.borrowLimit);
    final windowErr  = ValidationUtils.validateRepaymentWindow(state.repaymentWindow);
    final penaltyErr = ValidationUtils.validatePenalty(state.penalty);
    emit(state.copyWith(
      borrowLimitError:     limitErr,
      repaymentWindowError: windowErr,
      penaltyError:         penaltyErr,
    ));
    return limitErr == null && windowErr == null && penaltyErr == null;
  }

  // ── Reset ────────────────────────────────────────────────────────────────
  void reset() => emit(const CreateProjectForm());
}
