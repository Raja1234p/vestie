import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vestie/app/router/route_args/project_detail_flow_args.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/leader/features/project_detail/presentation/pages/voting_started_success_screen.dart';

void main() {
  testWidgets('VotingStartedSuccessScreen shows Figma copy and CTA', (
    tester,
  ) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (_, __) => const MaterialApp(
          home: VotingStartedSuccessScreen(
            args: VotingStartedSuccessRouteArgs(projectId: 'p1'),
          ),
        ),
      ),
    );

    expect(find.text(AppStrings.votingStartedSuccessTitle), findsOneWidget);
    expect(find.text(AppStrings.votingStartedSuccessSubtitle), findsOneWidget);
    expect(find.text(AppStrings.btnBackToProject), findsOneWidget);
  });
}
