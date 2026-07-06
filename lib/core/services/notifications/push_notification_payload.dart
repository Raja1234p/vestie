import 'dart:convert';

/// Notification `type` values sent in the FCM `data` payload — add new cases
/// here as the backend introduces them. Unknown values map to [unknown] so
/// tap-routing can no-op safely instead of crashing on an unrecognized type.
enum PushNotificationType {
  projectCreated,
  /// Wallet-tab routing — explicit `WithdrawalFailed` / `Deposit*` types and
  /// any notify copy whose `type`, `title`, or `body` contains "withdrawal"
  /// or "deposit" (case-insensitive).
  withdrawalFailed,
  unknown;

  static PushNotificationType fromWire(String? value) {
    switch (value) {
      case 'ProjectCreated':
        return PushNotificationType.projectCreated;
      case 'WithdrawalFailed':
        return PushNotificationType.withdrawalFailed;
      default:
        return walletTypeIfTextMatches(value);
    }
  }

  /// Maps wallet-related notify text to [withdrawalFailed] (opens Wallet tab).
  static PushNotificationType walletTypeIfTextMatches(String? text) {
    if (text == null || text.isEmpty) return PushNotificationType.unknown;
    final lower = text.toLowerCase();
    if (lower.contains('withdrawal') || lower.contains('deposit')) {
      return PushNotificationType.withdrawalFailed;
    }
    return PushNotificationType.unknown;
  }
}

/// Typed view over an FCM `data` map. Every Vestie push carries `type`,
/// `title`, `body`, and a type-specific-fields map that is itself a
/// JSON-encoded string. The backend is inconsistent about the field name for
/// that map — `payload` on some types (`ProjectCreated`), `metadata` on
/// others (`WithdrawalFailed`) — so [fromData] checks `payload` first, then
/// falls back to `metadata`. E.g.:
///
/// ```json
/// {
///   "type": "ProjectCreated",
///   "title": "Project Created",
///   "body": "Your project ddd has been created successfully.",
///   "payload": "{\"projectId\":\"4f78d1af-...\",\"projectName\":\"ddd\"}"
/// }
/// ```
///
/// ```json
/// {
///   "type": "WithdrawalFailed",
///   "title": "Withdrawal Failed",
///   "body": "Your withdrawal of $500 could not be processed. Please try again.",
///   "metadata": "{\"withdrawalId\":\"4c63d3e2-...\",\"amount\":500.00,\"currency\":\"USD\",\"status\":\"Failed\",\"failureReason\":\"...\"}"
/// }
/// ```
class PushNotificationPayload {
  final PushNotificationType type;
  final String title;
  final String body;
  final Map<String, dynamic> payload;

  const PushNotificationPayload({
    required this.type,
    required this.title,
    required this.body,
    required this.payload,
  });

  factory PushNotificationPayload.fromData(Map<String, dynamic> data) {
    final title = data['title']?.toString() ?? '';
    final body = data['body']?.toString() ?? '';
    final wireType = data['type']?.toString();

    var type = PushNotificationType.fromWire(wireType);
    if (type == PushNotificationType.unknown) {
      type = PushNotificationType.walletTypeIfTextMatches('$title $body');
    }

    return PushNotificationPayload(
      type: type,
      title: title,
      body: body,
      payload: _decodePayload(data['payload'] ?? data['metadata']),
    );
  }

  static Map<String, dynamic> _decodePayload(Object? raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is String && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) return decoded;
      } catch (_) {
        // Malformed payload string — fall through to empty map below.
      }
    }
    return const {};
  }

  String? get projectId => payload['projectId']?.toString();
  String? get projectName => payload['projectName']?.toString();

  String? get withdrawalId => payload['withdrawalId']?.toString();
  double? get withdrawalAmount => double.tryParse(
    payload['amount']?.toString() ?? '',
  );
  String? get withdrawalCurrency => payload['currency']?.toString();
  String? get withdrawalStatus => payload['status']?.toString();
  String? get withdrawalFailureReason =>
      payload['failureReason']?.toString();

  @override
  String toString() =>
      'PushNotificationPayload(type: $type, title: $title, body: $body, payload: $payload)';
}
