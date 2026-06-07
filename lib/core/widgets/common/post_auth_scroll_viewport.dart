import 'package:flutter/material.dart';

/// Applies top [SafeArea] for scroll-only bodies (e.g. Discover empty/error).
///
/// Screens with a [PostAuthHeader] should use `Column(header, Expanded(body))`
/// so the gradient band extends under the status bar — do not wrap the header.
final class PostAuthScrollViewport extends StatelessWidget {
  final Widget child;

  const PostAuthScrollViewport({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(bottom: false, child: child);
  }
}
