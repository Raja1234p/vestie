/// Synchronous guard against overlapping inbox accept/decline calls.
///
/// Prevents a second tap from entering the cubit before [actingRow] is emitted.
mixin UserVffInboxMutationGuardMixin {
  bool _inboxMutationInFlight = false;

  bool beginInboxMutation() {
    if (_inboxMutationInFlight) return false;
    _inboxMutationInFlight = true;
    return true;
  }

  void endInboxMutation() {
    _inboxMutationInFlight = false;
  }
}
