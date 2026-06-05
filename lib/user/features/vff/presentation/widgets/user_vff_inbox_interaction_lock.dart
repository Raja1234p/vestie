import 'package:flutter/material.dart';

/// Blocks taps/scroll on inbox lists while one accept/decline is in flight.
///
/// Transparent [AbsorbPointer] — no extra loader; the active row keeps its
/// button spinner. Cheap to build (single overlay, no per-card guards).
class UserVffInboxInteractionLock extends StatelessWidget {
  final bool locked;
  final Widget child;

  const UserVffInboxInteractionLock({
    super.key,
    required this.locked,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (!locked) return child;

    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        const Positioned.fill(
          child: AbsorbPointer(
            child: SizedBox.expand(),
          ),
        ),
      ],
    );
  }
}
