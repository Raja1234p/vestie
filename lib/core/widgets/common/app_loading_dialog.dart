import 'package:flutter/material.dart';

import '../../constants/app_strings.dart';
import '../../theme/app_colors.dart';
import 'app_loading_overlay.dart';

/// Non-dismissible full-screen scrim with [AppLoader]. Caller must pop the route.
///
/// Use [body] when you need to wrap the overlay (e.g. [BlocListener] to auto-dismiss).
class AppLoadingDialog {
  AppLoadingDialog._();

  /// Visual root for [show] or for custom `showDialog` + listeners.
  static Widget body({String message = AppStrings.loading}) {
    return PopScope(
      canPop: false,
      child: Material(
        type: MaterialType.transparency,
        child: SizedBox.expand(
          child: ColoredBox(
            color: AppColors.modalBarrier,
            child: Center(
              child: AppLoadingScrimContent(message: message),
            ),
          ),
        ),
      ),
    );
  }

  static Future<void> show(
    BuildContext context, {
    String message = AppStrings.loading,
  }) {
    return showDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (_) => body(message: message),
    );
  }
}
