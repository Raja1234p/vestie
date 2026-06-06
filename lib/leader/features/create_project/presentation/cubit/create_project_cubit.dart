import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vestie/core/utils/validation_utils.dart';
import '../../domain/create_project_form.dart';

/// Wizard state — amount, details, flow-specific settings (saving vs borrowing vs simple).
class CreateProjectCubit extends Cubit<CreateProjectForm> {
  CreateProjectCubit() : super(const CreateProjectForm());

  /// Calendar date in local time (avoids [DateUtils.dateOnly] UTC shifts on picker days).
  static DateTime calendarDate(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  // ── Amount ─────────────────────────────────────────────────────────────
  void appendAmountDigit(String d) {
    if (state.amountDigits.isEmpty && d == '0') return;
    if (state.amountDigits.length >= 7) return;
    emit(state.copyWith(amountDigits: state.amountDigits + d));
  }

  void removeAmountDigit() {
    if (state.amountDigits.isEmpty) return;
    emit(
      state.copyWith(
        amountDigits: state.amountDigits.substring(
          0,
          state.amountDigits.length - 1,
        ),
      ),
    );
  }

  // ── Details ────────────────────────────────────────────────────────────
  void setProjectName(String v) =>
      emit(state.copyWith(projectName: v, nameError: null));

  void setDescription(String v) =>
      emit(state.copyWith(description: v, descError: null));

  void setCategory(NewProjectCategory c) {
    var roi = state.roi;
    final ProjectCreationFlowType nextFlow = switch (c) {
      NewProjectCategory.investment =>
        ProjectCreationFlowType.investmentOptionalRoi,
      NewProjectCategory.vacation => ProjectCreationFlowType.fundsBorrowing,
      NewProjectCategory.emergency => ProjectCreationFlowType.fundsBorrowing,
    };
    if (state.flowType == ProjectCreationFlowType.investmentOptionalRoi &&
        nextFlow != ProjectCreationFlowType.investmentOptionalRoi) {
      roi = '';
    }
    emit(
      state.copyWith(category: c, flowType: nextFlow, roi: roi, roiError: null),
    );
  }

  void setDeadline(DateTime d) {
    emit(state.copyWith(deadline: calendarDate(d), deadlineError: null));
  }

  void clearDeadline() {
    emit(state.copyWith(deadline: null, deadlineError: null));
  }

  void setVisibility(ProjectVisibility v) =>
      emit(state.copyWith(visibility: v));

  // ── Collaborative saving (Project Settings) ───────────────────────────
  void setAutoSaveEnabled(bool v) => emit(state.copyWith(autoSaveEnabled: v));

  // ── Funds borrowing ─────────────────────────────────────────────────────
  /// Digits only — `%` is appended in the field for display, not sent to the API.
  void setRoi(String v) {
    final digits = v.replaceAll(RegExp(r'[^0-9]'), '');
    emit(state.copyWith(roi: digits, roiError: null));
  }

  void toggleBorrowing(bool v) => emit(
    state.copyWith(
      borrowingEnabled: v,
      repaymentWindowError: null,
      penaltyError: null,
    ),
  );
  void setRepaymentDays(String v) =>
      emit(state.copyWith(repaymentWindow: v, repaymentWindowError: null));
  void setPenalty(String v) =>
      emit(state.copyWith(penalty: v, penaltyError: null));

  // ── Validation ─────────────────────────────────────────────────────────
  bool validateDetails() {
    final nameErr = ValidationUtils.validateProjectName(state.projectName);
    final descErr = ValidationUtils.validateProjectDescription(
      state.description,
    );
    emit(
      state.copyWith(
        nameError: nameErr,
        descError: descErr,
        deadlineError: null,
      ),
    );
    return nameErr == null && descErr == null;
  }

  bool validateFundsBorrowing() {
    if (!state.borrowingEnabled) return true;
    final daysErr = ValidationUtils.validateRepaymentDays(
      state.repaymentWindow,
    );
    final penErr = ValidationUtils.validatePenalty(state.penalty);
    emit(
      state.copyWith(
        repaymentWindowError: daysErr,
        penaltyError: penErr,
        roiError: null,
      ),
    );
    return daysErr == null && penErr == null;
  }

  bool validateInvestmentOptionalRoi() {
    final roiErr = ValidationUtils.validateOptionalAnnualRoiPercent(state.roi);
    emit(state.copyWith(roiError: roiErr));
    return roiErr == null;
  }

  void reset() => emit(const CreateProjectForm());
}
