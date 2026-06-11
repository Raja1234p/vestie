import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:vestie/core/constants/app_dimens.dart';

/// Project detail scroll bottom insets — Android nav bar vs iOS home indicator.
abstract final class ProjectDetailScrollInsets {
  ProjectDetailScrollInsets._();

  /// Android 3-button nav: shrink scroll viewport with [SafeArea].
  /// iOS has no nav bar strip — home indicator handled in [scrollBottomGap] only.
  static final bool applyBottomSafeAreaToViewport =
      defaultTargetPlatform == TargetPlatform.android;

  /// Trailing gap at the end of project detail scroll content.
  static double scrollBottomGap(BuildContext context) {
    final design = AppDimens.projectDetailScrollBottomGap;
    if (applyBottomSafeAreaToViewport) {
      return design;
    }
    final systemBottom = MediaQuery.viewPaddingOf(context).bottom;
    if (systemBottom <= 0) return design;
    return math.max(design, systemBottom + AppDimens.v8);
  }
}
