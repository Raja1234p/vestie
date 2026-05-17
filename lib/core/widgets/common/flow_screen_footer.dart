import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Pinned footer inset for flow screens (Android nav bar + iOS home indicator).
class FlowScreenFooter extends StatelessWidget {
  final Widget child;

  const FlowScreenFooter({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final viewBottom = MediaQuery.viewPaddingOf(context).bottom;
    final bottom = math.max(24.h, viewBottom + 8.h);

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, bottom),
      child: child,
    );
  }
}
