import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Monotone noise overlay for payment card surfaces (Figma #DFD9ED).
class PaymentCardNoisePainter extends CustomPainter {
  const PaymentCardNoisePainter({this.seed = 7});

  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(seed);
    final pointCount = (size.width * size.height * 0.22).round().clamp(120, 2800);
    final paint = Paint()..style = PaintingStyle.fill;

    for (var i = 0; i < pointCount; i++) {
      final alpha = 0.12 + random.nextDouble() * 0.38;
      paint.color = AppColors.payCardNoise.withValues(alpha: alpha);
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        0.35 + random.nextDouble() * 0.65,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant PaymentCardNoisePainter oldDelegate) =>
      oldDelegate.seed != seed;
}
