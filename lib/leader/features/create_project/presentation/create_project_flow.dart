import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/app_routes.dart';
import '../domain/create_project_form.dart';
import 'create_project_entry_mode.dart';
import 'cubit/create_project_cubit.dart';

String? createProjectDetailsStepBadge(
  CreateProjectForm form, {
  required bool editMode,
}) {
  if (editMode) return null;
  // Amount is outside 1/3–3/3 (vacation·borrow, emergency·borrow, investment·ROI).
  if (form.flowType == ProjectCreationFlowType.fundsBorrowing ||
      form.flowType == ProjectCreationFlowType.investmentOptionalRoi) {
    return '1/3';
  }
  return '2/${form.flowType.wizardStepTotal}';
}

String? createProjectSavingSettingsStepBadge(
  CreateProjectForm form, {
  required bool editMode,
}) {
  if (editMode) return null;
  return '3/${form.flowType.wizardStepTotal}';
}

String? createProjectBorrowingSettingsStepBadge(
  CreateProjectForm form, {
  required bool editMode,
}) {
  if (editMode) return null;
  if (form.flowType == ProjectCreationFlowType.fundsBorrowing) {
    return '2/3';
  }
  return '3/${form.flowType.wizardStepTotal}';
}

String createProjectReviewStepBadge(CreateProjectForm form) {
  if (form.flowType == ProjectCreationFlowType.fundsBorrowing ||
      form.flowType == ProjectCreationFlowType.investmentOptionalRoi) {
    return '3/3';
  }
  return '${form.flowType.wizardStepTotal}/${form.flowType.wizardStepTotal}';
}

String? createProjectInvestmentSettingsStepBadge(
  CreateProjectForm form, {
  required bool editMode,
}) {
  if (editMode) return null;
  if (form.flowType == ProjectCreationFlowType.investmentOptionalRoi) {
    return '2/3';
  }
  return '3/${form.flowType.wizardStepTotal}';
}

/// After validating details, routes to Saving settings, Borrowing settings, or Review.
void pushNextAfterDetailsStep(
  BuildContext context,
  CreateProjectCubit cubit, {
  required CreateProjectEntryMode entryMode,
}) {
  if (!cubit.validateDetails()) return;
  final form = cubit.state;

  if (entryMode.isEditFlow) {
    switch (form.flowType) {
      case ProjectCreationFlowType.collaborativeSaving:
        context.push(AppRoutes.createProjectSavingSettings, extra: entryMode);
      case ProjectCreationFlowType.fundsBorrowing:
        context.push(AppRoutes.createProjectFundsBorrowing, extra: entryMode);
      case ProjectCreationFlowType.streamlined:
        context.pop();
      case ProjectCreationFlowType.investmentOptionalRoi:
        context.push(
          AppRoutes.createProjectInvestmentSettings,
          extra: entryMode,
        );
    }
    return;
  }

  // Wizard and review-screen edit share forward navigation (settings → review).
  final settingsExtra =
      entryMode.isEditFromReview ? entryMode : null;

  switch (form.flowType) {
    case ProjectCreationFlowType.collaborativeSaving:
      context.push(AppRoutes.createProjectSavingSettings, extra: settingsExtra);
    case ProjectCreationFlowType.fundsBorrowing:
      context.push(AppRoutes.createProjectFundsBorrowing, extra: settingsExtra);
    case ProjectCreationFlowType.streamlined:
      context.push(AppRoutes.createProjectReview);
    case ProjectCreationFlowType.investmentOptionalRoi:
      context.push(
        AppRoutes.createProjectInvestmentSettings,
        extra: settingsExtra,
      );
  }
}
