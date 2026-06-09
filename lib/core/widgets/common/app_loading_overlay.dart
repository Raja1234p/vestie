import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/app_colors.dart';
import '../text/app_text.dart';
import 'app_loader.dart';

/// Centred loader with optional caption (for scrim overlays).
class AppLoadingScrimContent extends StatelessWidget {
  final String? message;
  final Color? captionColor;

  const AppLoadingScrimContent({
    super.key,
    this.message,
    this.captionColor,
  });

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
              color: captionColor ?? Colors.white,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }
}

/// Blocks interaction over [child] with an optional scrim and centred [AppLoader].
///
/// On post-gradient screens use [scrimColor] [AppColors.postAuthLoadingOverlayScrim]
/// and wrap the full `Column` (header + body) so the loader does not split the layout.
class AppLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  /// Defaults to [AppColors.modalBarrier]. Use [AppColors.postAuthLoadingOverlayScrim]
  /// on gradient flows so content stays visible underneath.
  final Color? scrimColor;

  const AppLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
    this.scrimColor,
  });

  Color get _resolvedScrim => scrimColor ?? AppColors.modalBarrier;

  bool get _usesTransparentScrim => _resolvedScrim.a == 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: AbsorbPointer(
              child: _usesTransparentScrim
                  ? Center(
                      child: AppLoadingScrimContent(
                        message: message,
                        captionColor: AppColors.grey1100,
                      ),
                    )
                  : ColoredBox(
                      color: _resolvedScrim,
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
