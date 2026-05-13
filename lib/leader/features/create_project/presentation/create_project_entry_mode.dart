/// How the user entered a create-project wizard screen (carried on [GoRouterState.extra]).
enum CreateProjectEntryMode {
  /// Normal creation flow — primary actions use Next.
  wizard,

  /// Leader edits an existing project from project detail.
  editFromProjectDetail,

  /// User tapped Edit on the review screen — settings steps still use Next (same as wizard).
  editFromReview,
}

extension CreateProjectEntryModeX on CreateProjectEntryMode {
  bool get isEditFlow => this != CreateProjectEntryMode.wizard;
}

/// Parses route `extra` from [GoRoute]. Legacy `extra == true` → [editFromProjectDetail].
CreateProjectEntryMode createProjectEntryModeFromExtra(Object? extra) {
  if (extra is CreateProjectEntryMode) return extra;
  if (extra == true) return CreateProjectEntryMode.editFromProjectDetail;
  return CreateProjectEntryMode.wizard;
}
