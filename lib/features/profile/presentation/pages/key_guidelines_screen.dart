import 'package:flutter/material.dart';
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
              width: double.infinity, // Makes it stretch all the way across the screen
              height: 150,            // The height of your header area
              child: CustomPaint(
                painter: CombinedGradientPainter(), // <--- Right here!
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
    // 1. Define the bounding box
    final Rect rect = Offset.zero & size;

    // 2. The Multi-Stop Gradient Magic
    final Paint paint = Paint()
      ..shader = const LinearGradient(
        // We start strictly at the top left
        begin: Alignment.topLeft,
        // We pull the end point slightly inward to create that sweeping wash of white
        end: Alignment(0.6, 1.0),
        colors: [
          Color(0xFF8E54E9), // 1. The vibrant, deep purple anchor
          Color(0xFFC9AFFF), // 2. The softening mid-tone purple
          Colors.white,      // 3. The pure white finish
        ],
        // The Stops: This is what makes it look like your image.
        // It holds the deep purple slightly, transitions smoothly through the middle,
        // and hits pure white just before the bottom edge.
        stops: [0.0, 0.45, 0.95],
      ).createShader(rect)
      ..style = PaintingStyle.fill;

    // 3. The Shape (Rounded Top, Sharp Bottom)
    final RRect rrect = RRect.fromRectAndCorners(
      rect,
      topLeft: Radius.zero,
      topRight: Radius.zero,
      bottomLeft: Radius.zero,
      bottomRight: Radius.zero,
    );

    // 4. Paint it!
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}