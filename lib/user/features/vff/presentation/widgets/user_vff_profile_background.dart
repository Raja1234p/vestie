import 'package:flutter/material.dart';

import 'package:vestie/core/constants/app_assets.dart';

/// Full-screen background image for the VFF user detail (peer profile) screen.
final class UserVffProfileBackground extends StatelessWidget {
  final Widget child;

  const UserVffProfileBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: Image.asset(
            AppAssets.vffProfileBackground,
            fit: BoxFit.fill,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        child,
      ],
    );
  }
}
