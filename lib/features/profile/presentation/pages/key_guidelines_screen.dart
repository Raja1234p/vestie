import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/post_auth_gradient_background.dart';

class KeyGuidelinesScreen extends StatelessWidget {
  const KeyGuidelinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PostAuthGradientBackground(
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 150,
              child: CustomPaint(
                painter: CombinedGradientPainter(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}






class CombinedGradientPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;

    final Paint paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment(0.6, 1.0),
        colors: [
          AppColors.purple600,
          AppColors.purple400,
          AppColors.surface,
        ],
        stops: [0.0, 0.45, 0.95],
      ).createShader(rect)
      ..style = PaintingStyle.fill;

    final RRect rrect = RRect.fromRectAndCorners(
      rect,
      topLeft: Radius.zero,
      topRight: Radius.zero,
      bottomLeft: Radius.zero,
      bottomRight: Radius.zero,
    );

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}