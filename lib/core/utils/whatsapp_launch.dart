import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Builds `whatsapp://send?text=…` with correct encoding (Android + iOS).
Uri _whatsappAppUri(String message) {
  return Uri(
    scheme: 'whatsapp',
    host: 'send',
    queryParameters: {'text': message},
  );
}

/// Official “click to chat” HTTPS URL (no phone).
Uri _waMeUri(String message) {
  return Uri.https('wa.me', '/', {'text': message});
}

/// Alternate WhatsApp Web deep link some devices resolve more reliably.
Uri _apiWhatsappSendUri(String message) {
  return Uri.https('api.whatsapp.com', '/send', {'text': message});
}

Future<bool> _tryLaunchUri(Uri uri) async {
  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}

/// Opens WhatsApp with [message] as prefilled text on **Android** and **iOS**.
///
/// Order:
/// 1. `whatsapp://send` — opens the app when installed.
/// 2. `https://wa.me/?text=` — universal link / browser fallback.
/// 3. `https://api.whatsapp.com/send?text=` — second HTTPS fallback.
/// 4. System share sheet ([Share.share]) — user can pick WhatsApp or any app.
///
/// Does not use [canLaunchUrl] (avoids Android `flutter.dev` probe noise).
Future<bool> launchWhatsAppShareText(String message) async {
  final trimmed = message.trim();
  if (trimmed.isEmpty) return false;

  if (!kIsWeb) {
    if (await _tryLaunchUri(_whatsappAppUri(trimmed))) return true;
  }

  if (await _tryLaunchUri(_waMeUri(trimmed))) return true;

  if (await _tryLaunchUri(_apiWhatsappSendUri(trimmed))) return true;

  if (kIsWeb) return false;

  try {
    final result = await Share.share(trimmed);
    return result.status == ShareResultStatus.success ||
        result.status == ShareResultStatus.dismissed;
  } catch (_) {
    return false;
  }
}
