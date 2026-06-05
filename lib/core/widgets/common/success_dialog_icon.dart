import 'package:flutter/material.dart';

import '../../constants/app_assets.dart';
import '../../constants/app_dimens.dart';

/// Standard size for [AppAssets.successProjectCreated] in success dialogs — 132×145.
class SuccessDialogIcon extends StatelessWidget {
  const SuccessDialogIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppAssets.successProjectCreated,
      width: AppDimens.successDialogIconWidth,
      height: AppDimens.successDialogIconHeight,
      fit: BoxFit.contain,
    );
  }
}
