import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Bundled SVG glyph — use instead of [Icon] + [Icons] for consistent rendering.
class AppSvgIcon extends StatelessWidget {
  final String assetPath;
  final double size;
  final Color? color;

  const AppSvgIcon({
    super.key,
    required this.assetPath,
    required this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      colorFilter:
          color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
    );
  }
}
