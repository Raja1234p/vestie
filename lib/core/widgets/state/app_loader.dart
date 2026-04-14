import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A reusable global loader widget that enforces the design system and avoids hardcoding sizes.
class AppLoader extends StatelessWidget {
  final double? size;
  final Color? color;
  final double strokeWidth;

  const AppLoader({
    super.key,
    this.size,
    this.color,
    this.strokeWidth = 3.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: size ?? 40.w,
        width: size ?? 40.w,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
