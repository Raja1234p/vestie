import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vestie/core/utils/validation_utils.dart';
import '../../domain/create_project_form.dart';

/// Wizard state — amount, details, flow-specific settings (saving vs borrowing vs simple).
class CreateProjectCubit extends Cubit<CreateProjectForm> {
  CreateProjectCubit() : super(const CreateProjectForm());

  // ── Amount ─────────────────────────────────────────────────────────────
  void appendAmountDigit(String d) {
    if (state.amountDigits.isEmpty && d == '0') return;
    if (state.amountDigits.length >= 7) return;
    emit(state.copyWith(amountDigits: state.amountDigits + d));
  }

  void removeAmountDigit() {
    if (state.amountDigits.isEmpty) return;
    emit(state.copyWith(
        amountDigits:
            state.amountDigits.substring(0, state.amountDigits.length - 1)));
  }

  // ── Details ────────────────────────────────────────────────────────────
  void setCreationFlow(ProjectCreationFlowType t) =>
      emit(state.copyWith(flowType: t));

  void setProjectName(String v) =>
      emit(state.copyWith(projectName: v, nameError: null));

  void setDescription(String v) =>
      emit(state.copyWith(description: v, descError: null));

  void setCategory(NewProjectCategory c) => emit(state.copyWith(category: c));

  void setDeadline(DateTime d) =>
      emit(state.copyWith(deadline: d, deadlineError: null));

  void setVisibility(ProjectVisibility v) =>
      emit(state.copyWith(visibility: v));

  // ── Collaborative saving (Project Settings) ───────────────────────────
  void setAutoSaveEnabled(bool v) => emit(state.copyWith(autoSaveEnabled: v));

  // ── Funds borrowing ─────────────────────────────────────────────────────
  void setRoi(String v) => emit(state.copyWith(roi: v, roiError: null));
  void toggleBorrowing(bool v) => emit(state.copyWith(borrowingEnabled: v));
  void setRepaymentMonths(String v) =>
      emit(state.copyWith(repaymentWindow: v, repaymentWindowError: null));

  // ── Validation ─────────────────────────────────────────────────────────
  bool validateDetails() {
    final nameErr =
        ValidationUtils.validateProjectName(state.projectName);
    final descErr =
        ValidationUtils.validateProjectDescription(state.description);
    final deadlineErr =
        ValidationUtils.validateProjectDeadline(state.deadline);
    emit(state.copyWith(
      nameError: nameErr,
      descError: descErr,
      deadlineError: deadlineErr,
    ));
    return nameErr == null && descErr == null && deadlineErr == null;
  }

  bool validateFundsBorrowing() {
    if (!state.borrowingEnabled) return true;
    final roiErr = ValidationUtils.validateAnnualRoiPercent(state.roi);
    final winErr = ValidationUtils.validateRepaymentMonths(state.repaymentWindow);
    emit(state.copyWith(roiError: roiErr, repaymentWindowError: winErr));
    return roiErr == null && winErr == null;
  }

  void reset() => emit(const CreateProjectForm());
}
