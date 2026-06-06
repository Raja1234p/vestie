import 'package:flutter/material.dart';

/// Constrains [child] scroll content below the status bar while a parent
/// background ([PostAuthGradientBackground], [HomeGradientBackground], etc.)
/// can still paint edge-to-edge.
///
/// Pair with [PostAuthHeader] `applyTopSafeArea: false` when the header is the
/// first sliver/child inside [child].
final class PostAuthScrollViewport extends StatelessWidget {
  final Widget child;

  const PostAuthScrollViewport({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(bottom: false, child: child);
  }
}
