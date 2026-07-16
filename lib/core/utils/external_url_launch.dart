import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/widgets/common/app_toast.dart';

/// Opens [url] in the system browser (not an in-app WebView).
Future<void> launchExternalUrl(BuildContext context, String url) async {
  final uri = Uri.tryParse(url.trim());
  if (uri == null || !uri.hasScheme) {
    if (context.mounted) {
      AppToast.showError(context, AppStrings.errorExternalLinkLaunchFailed);
    }
    return;
  }

  try {
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched && context.mounted) {
      AppToast.showError(context, AppStrings.errorExternalLinkLaunchFailed);
    }
  } catch (_) {
    if (context.mounted) {
      AppToast.showError(context, AppStrings.errorExternalLinkLaunchFailed);
    }
  }
}
