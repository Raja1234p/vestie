import 'package:flutter/material.dart';

/// Constrains [child] scroll content below the status bar while a parent
/// white shell ([PostAuthGradientBackground]) and header band layout apply.
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
