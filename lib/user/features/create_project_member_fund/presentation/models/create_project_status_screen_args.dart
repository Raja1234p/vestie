import 'create_project_fund_draft.dart';

/// Parameters for [`CreateProjectStatusScreen`] (success vs failure mocks).
class CreateProjectStatusScreenArgs {
  final bool success;
  final CreateProjectFundDraft draft;

  const CreateProjectStatusScreenArgs({
    required this.success,
    required this.draft,
  });
}
