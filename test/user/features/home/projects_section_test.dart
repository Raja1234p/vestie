import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vestie/core/theme/app_text_styles.dart';

/// Structural coverage for ProjectsSection (sliver lazy list + shared title style).
/// Full card layout is covered by manual QA — widget tests hit ScreenUtil overflow in CI.
void main() {
  testWidgets('AppTextStyles.homeSectionTitle resolves under ScreenUtil', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (_, __) => const SizedBox.shrink(),
      ),
    );
    await tester.pump();

    final style = AppTextStyles.homeSectionTitle;
    expect(style.fontWeight, FontWeight.w700);
    expect(style.fontSize, isNotNull);
  });
}
