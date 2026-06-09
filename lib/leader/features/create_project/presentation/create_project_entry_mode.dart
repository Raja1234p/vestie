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
  /// Leader editing a **live** project from project detail (category/visibility locked).
  bool get isEditFromProjectDetail =>
      this == CreateProjectEntryMode.editFromProjectDetail;

  /// Same as [isEditFromProjectDetail] — not used for review-screen draft edits.
  bool get isEditFlow => isEditFromProjectDetail;

  /// Create wizard: user tapped Edit on review to adjust draft details locally.
  bool get isEditFromReview =>
      this == CreateProjectEntryMode.editFromReview;
}

/// Parses route `extra` from [GoRoute]. Legacy `extra == true` → [editFromProjectDetail].
CreateProjectEntryMode createProjectEntryModeFromExtra(Object? extra) {
  if (extra is CreateProjectEntryMode) return extra;
  if (extra == true) return CreateProjectEntryMode.editFromProjectDetail;
  return CreateProjectEntryMode.wizard;
}
