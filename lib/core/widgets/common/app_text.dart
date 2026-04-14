import 'package:flutter/material.dart';

/// Wrapper over [Text] — enforces no raw Text() calls in UI.
/// Defaults to bodyMedium from the active theme.
class AppText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final Color? color;

  const AppText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final base = style ?? Theme.of(context).textTheme.bodyMedium;
    return Text(
      text,
      style: color != null ? base?.copyWith(color: color) : base,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
