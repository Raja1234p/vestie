import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/app_colors.dart';

/// Dashed line using [AppColors.purple300] — full width of parent, no horizontal
/// inset (use in cards so only row content has side padding, not the line).
class AppPurpleDashedLine extends StatelessWidget {
  const AppPurpleDashedLine({super.key, this.height = 2});

  final double height;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        return CustomPaint(
          size: Size(c.maxWidth, height.h),
          painter: const _PurpleDashPainter(
            color: AppColors.purple300,
            strokeWidth: 1.5,
          ),
        );
      },
    );
  }
}

class _PurpleDashPainter extends CustomPainter {
  const _PurpleDashPainter({required this.color, required this.strokeWidth});

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 5.0;
    const gap = 6.0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    var x = 0.0;
    final y = size.height * 0.5;
    while (x < size.width) {
      final end = (x + dashWidth).clamp(0.0, size.width);
      canvas.drawLine(Offset(x, y), Offset(end, y), paint);
      x += dashWidth + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _PurpleDashPainter o) =>
      o.color != color || o.strokeWidth != strokeWidth;
}
