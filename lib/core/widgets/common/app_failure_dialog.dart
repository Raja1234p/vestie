import 'package:flutter/material.dart';

import '../../error/failures.dart';
import 'app_toast.dart';

/// @deprecated Use [AppToast.showError] / [AppToast.showApiFailure] for API errors.
class AppFailureDialog {
  AppFailureDialog._();

  static Future<void> show(
    BuildContext context, {
    required String message,
    String? title,
    VoidCallback? onRetry,
  }) {
    AppToast.showError(context, message);
    return Future.value();
  }

  static Future<void> showFailure(
    BuildContext context, {
    required Failure failure,
    VoidCallback? onRetry,
  }) {
    AppToast.showApiFailure(context, failure);
    return Future.value();
  }
}
