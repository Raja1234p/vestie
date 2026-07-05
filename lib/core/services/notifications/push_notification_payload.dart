import 'dart:convert';

/// Notification `type` values sent in the FCM `data` payload — add new cases
/// here as the backend introduces them. Unknown values map to [unknown] so
/// tap-routing can no-op safely instead of crashing on an unrecognized type.
enum PushNotificationType {
  projectCreated,
  unknown;

  static PushNotificationType fromWire(String? value) {
    switch (value) {
      case 'ProjectCreated':
        return PushNotificationType.projectCreated;
      default:
        return PushNotificationType.unknown;
    }
  }
}

/// Typed view over an FCM `data` map. Every Vestie push carries `type`,
/// `title`, `body`, and a `payload` field that is itself a JSON-encoded
/// string with the type-specific routing fields, e.g.:
///
/// ```json
/// {
///   "type": "ProjectCreated",
///   "title": "Project Created",
///   "body": "Your project ddd has been created successfully.",
///   "payload": "{\"projectId\":\"4f78d1af-...\",\"projectName\":\"ddd\"}"
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
    return PushNotificationPayload(
      type: PushNotificationType.fromWire(data['type']?.toString()),
      title: data['title']?.toString() ?? '',
      body: data['body']?.toString() ?? '',
      payload: _decodePayload(data['payload']),
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

  @override
  String toString() =>
      'PushNotificationPayload(type: $type, title: $title, body: $body, payload: $payload)';
}
