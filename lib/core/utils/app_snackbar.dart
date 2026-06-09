/// Deprecated — use [AppToast] directly (`lib/core/widgets/common/app_toast.dart`).
@Deprecated('Use AppToast.showError / showSuccess / showInfo instead.')
library;

import 'package:flutter/material.dart';

import '../widgets/common/app_toast.dart';

@Deprecated('Use AppToast instead.')
class AppSnackBar {
  AppSnackBar._();

  @Deprecated('Use AppToast.showError')
  static void showError(BuildContext context, String message) {
    AppToast.showError(context, message);
  }

  @Deprecated('Use AppToast.showSuccess')
  static void showSuccess(BuildContext context, String message) {
    AppToast.showSuccess(context, message);
  }

  @Deprecated('Use AppToast.showInfo')
  static void showInfo(BuildContext context, String message) {
    AppToast.showInfo(context, message);
  }
}
