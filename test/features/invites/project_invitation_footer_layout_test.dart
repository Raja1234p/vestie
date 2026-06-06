import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vestie/core/widgets/common/flow_screen_footer.dart';

/// Verifies the invite screen footer pattern: [FlowScreenFooter] below [Expanded].
void main() {
  testWidgets('FlowScreenFooter sits at bottom of full-height column', (
    tester,
  ) async {
    const screenHeight = 800.0;
    const footerLabel = 'Join Project';

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (_, __) => const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(size: Size(390, screenHeight)),
            child: Scaffold(
              body: SizedBox.expand(
                child: Column(
                  children: [
                    Expanded(child: Placeholder()),
                    FlowScreenFooter(
                      child: SizedBox(
                        height: 56,
                        child: Center(child: Text(footerLabel)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final columnRect = tester.getRect(find.byType(Column));
    final footerBottom = tester.getRect(find.text(footerLabel)).bottom;
    expect(
      footerBottom,
      closeTo(columnRect.bottom, 80),
      reason: 'Footer should align with bottom of full-height column',
    );
  });
}
