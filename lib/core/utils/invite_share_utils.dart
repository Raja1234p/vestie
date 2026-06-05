import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../constants/app_strings.dart';

Future<void> copyInviteLink(String link) async {
  await Clipboard.setData(ClipboardData(text: link));
}

/// Opens the OS share sheet (WhatsApp, Instagram, Messages, etc.).
///
/// [sharePositionOrigin] is required on iPad — pass the tapped chip bounds.
Future<bool> openInviteShareSheet({
  required String inviteLink,
  String? projectName,
  Rect? sharePositionOrigin,
}) async {
  final text = AppStrings.shareWhatsappMessage(inviteLink);
  try {
    final result = await Share.share(
      text,
      subject: projectName?.trim().isNotEmpty == true
          ? AppStrings.inviteMembersTitle(projectName!.trim())
          : null,
      sharePositionOrigin: sharePositionOrigin,
    );
    return result.status == ShareResultStatus.success ||
        result.status == ShareResultStatus.dismissed;
  } catch (_) {
    return false;
  }
}
