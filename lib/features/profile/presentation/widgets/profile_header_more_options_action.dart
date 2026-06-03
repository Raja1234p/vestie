import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_dimens.dart';

/// Profile tab header trailing control — 32×32 ([AppDimens.iconLarge]), like Home notification.
class ProfileHeaderMoreOptionsAction extends StatelessWidget {
  const ProfileHeaderMoreOptionsAction({super.key});

  @override
  Widget build(BuildContext context) {
    final extent = AppDimens.iconLarge;
    return SizedBox(
      width: extent,
      height: extent,
      child: Center(
        child: SvgPicture.asset(
          AppAssets.iconProfileMoreOptions,
          width: extent,
          height: extent,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
