import 'package:flutter/material.dart';
import '../../extensions/context_extensions.dart';

/// Reusable Text component ensuring styling remains restricted to Theme values.
class AppText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextOverflow? overflow;
  final int? maxLines;
  final TextAlign? textAlign;
  final Color? color;

  const AppText(
    this.text, {
    super.key,
    this.style,
    this.overflow,
    this.maxLines,
    this.textAlign,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Merge provided style or default to bodyLarge with any specific color override
    final effectiveStyle = (style ?? context.textTheme.bodyLarge)?.copyWith(
      color: color,
    );

    return Text(
      text,
      style: effectiveStyle,
      overflow: overflow,
      maxLines: maxLines,
      textAlign: textAlign,
    );
  }
}
