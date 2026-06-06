import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/app_colors.dart';
import '../text/app_text.dart';
import 'app_loader.dart';

/// Centred loader with optional caption (for scrim overlays).
class AppLoadingScrimContent extends StatelessWidget {
  final String? message;

  const AppLoadingScrimContent({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    final caption = message?.trim();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AppLoader(),
        if (caption != null && caption.isNotEmpty) ...[
          SizedBox(height: 16.h),
          AppText(
            caption,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }
}

/// Full-screen transparent scrim with centred [AppLoader] over [child].
class AppLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const AppLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
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
                color: AppColors.modalBarrier,
                child: Center(
                  child: AppLoadingScrimContent(message: message),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
