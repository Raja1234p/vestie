import 'package:flutter/material.dart';

import '../../constants/app_assets.dart';
import '../../constants/app_dimens.dart';

/// Standard size for [AppAssets.statusFailure] — 132×145 on all screens and dialogs.
class FailureIcon extends StatelessWidget {
  const FailureIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppAssets.statusFailure,
      width: AppDimens.failureIconWidth,
      height: AppDimens.failureIconHeight,
      fit: BoxFit.contain,
    );
  }
}
