/// Lets [FcmPushService] request a dashboard unread refresh without importing
/// presentation-layer cubits.
class NotificationUnreadRefresh {
  NotificationUnreadRefresh._();

  static Future<void> Function()? _refresh;

  static void register(Future<void> Function() refresh) {
    _refresh = refresh;
  }

  static void unregister() {
    _refresh = null;
  }

  static Future<void> requestRefresh() async {
    await _refresh?.call();
  }
}
