import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Pinned footer with home-indicator padding — matches announcement / flow screens.
class FlowScreenFooter extends StatelessWidget {
  final Widget child;

  const FlowScreenFooter({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
      child: child,
    );
  }
}
