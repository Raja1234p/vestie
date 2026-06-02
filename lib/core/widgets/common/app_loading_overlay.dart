import 'package:flutter/material.dart';

import 'app_loader.dart';

/// Full-screen transparent scrim with centred [AppLoader] over [child].
class AppLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const AppLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: AbsorbPointer(
              child: ColoredBox(
                color: Colors.black.withValues(alpha: 0.35),
                child: const AppLoader(),
              ),
            ),
          ),
      ],
    );
  }
}
