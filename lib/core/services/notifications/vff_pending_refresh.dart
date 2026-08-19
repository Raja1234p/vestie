/// Lets [FcmPushService] and [UserVffHubCubit] signal pending-state changes
/// to [VffPendingCubit] without importing presentation-layer cubits.
class VffPendingRefresh {
  VffPendingRefresh._();

  static void Function()? _markPending;
  static void Function()? _clearPending;
  static Future<void> Function()? _refresh;

  static void register({
    required void Function() markPending,
    required void Function() clearPending,
    required Future<void> Function() refresh,
  }) {
    _markPending = markPending;
    _clearPending = clearPending;
    _refresh = refresh;
  }

  static void unregister() {
    _markPending = null;
    _clearPending = null;
    _refresh = null;
  }

  /// Called by FCM foreground handler (or hub) when a VFF request push arrives.
  /// Sets the dot immediately without waiting for an API round-trip.
  static void notifyPending() => _markPending?.call();

  /// Called by hub after accept/decline empties the inbox.
  static void notifyClear() => _clearPending?.call();

  /// Called on dashboard open / app resume — probes the API for accuracy.
  static Future<void> requestRefresh() async => _refresh?.call();
}
